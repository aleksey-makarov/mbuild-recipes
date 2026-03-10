# Подход A: Bootstrap через кросс-компиляцию (по модели LFS)

## Обзор

Этот подход повторяет логику LFS: собираем кросс-тулчейн, кросс-компилируем временные утилиты, создаём чистый образ и пересобираем в нём всё нативно. Адаптировано под систему сборки с артефактами и podman-образами.

## Терминология

| Термин | Значение |
|--------|----------|
| **Артефакт** | Результат `make install DESTDIR=...` — срез файловой системы, копируемый в образ |
| **Образ** | Podman-образ, создаётся из слоёв с артефактами |
| **Рецепт** | Описание сборки: зависимости (образы + артефакты src) + build script |
| **host-image** | Начальный образ с хостовым тулчейном (например, Fedora/Debian minimal с gcc, make, etc.) |
| **cross-image** | Образ с кросс-тулчейном для сборки временных утилит |
| **temp-image** | Чистый образ (FROM scratch) с временными утилитами |
| **final-image** | Чистый образ с финальной системой |

## Общая схема

```
host-image (Fedora/Debian с gcc)
    │
    ├── [артефакты кросс-тулчейна: binutils-pass1, gcc-pass1, linux-headers, glibc, libstdc++]
    │       │
    │       ▼
    │   cross-image = host-image + артефакты кросс-тулчейна
    │       │
    │       ├── [артефакты временных утилит: m4, bash, coreutils, ..., binutils-pass2, gcc-pass2]
    │       │
    │       ▼
    │   temp-image = FROM scratch + linux-headers + glibc + libstdc++ + все временные утилиты + binutils-pass2 + gcc-pass2
    │       │
    │       ├── [артефакты chroot-утилит: gettext, bison, perl, python, texinfo, util-linux]
    │       │
    │       ▼
    │   build-image = temp-image + chroot-утилиты
    │       │
    │       ├── [артефакты финальной системы: glibc, gcc, bash, systemd, ...]
    │       │
    │       ▼
    │   final-image = FROM scratch + все финальные артефакты
```

---

## Фаза 1: Кросс-тулчейн

### Среда сборки

Все пакеты этой фазы собираются в **host-image**. Хостовый компилятор генерирует кросс-инструменты.

### Переменные

Рецепты этой фазы должны определять:
```
LFS_TGT=x86_64-lfs-linux-gnu    # целевой триплет (vendor=lfs)
```

### 1.1. binutils-pass1

**Зависимости:** host-image, src:binutils-2.45
**Build script:**
```bash
../configure \
    --prefix=/tools \
    --with-sysroot=/ \
    --target=$LFS_TGT \
    --disable-nls \
    --enable-gprofng=no \
    --disable-werror \
    --enable-new-dtags \
    --enable-default-hash-style=gnu

make
make install DESTDIR=$DESTDIR
```

**Артефакт содержит:**
```
/tools/bin/$LFS_TGT-as
/tools/bin/$LFS_TGT-ld
/tools/$LFS_TGT/bin/as
/tools/$LFS_TGT/bin/ld
/tools/lib/bfd-plugins/
...
```

**Prefix = `/tools`**: кросс-инструменты живут отдельно от целевой системы. В LFS это `$LFS/tools`, но поскольку артефакт копируется в образ, `/tools` в артефакте станет `/tools` в образе.

**`--with-sysroot=/`**: Линкер будет искать библиотеки относительно `/` (а не жёстко зашитого пути). Когда мы позже добавим glibc в `/usr/lib/` того же образа, линкер найдёт её.

**Примечание о sysroot:** В оригинальном LFS используется `--with-sysroot=$LFS`, потому что сборка идёт на хосте и целевые библиотеки лежат в `$LFS/`. В контейнерной системе целевые библиотеки будут установлены прямо в `/usr/lib/` образа, поэтому sysroot = `/`.

### 1.2. gcc-pass1

**Зависимости:** host-image + артефакт binutils-pass1, src:gcc-15.2.0, src:mpfr, src:gmp, src:mpc
**Build script:**
```bash
# Распаковать встроенные зависимости внутрь дерева gcc
tar -xf $SRC_MPFR -C gcc-15.2.0 && mv gcc-15.2.0/mpfr-* gcc-15.2.0/mpfr
tar -xf $SRC_GMP  -C gcc-15.2.0 && mv gcc-15.2.0/gmp-*  gcc-15.2.0/gmp
tar -xf $SRC_MPC  -C gcc-15.2.0 && mv gcc-15.2.0/mpc-*  gcc-15.2.0/mpc

# Установить целевой dynamic linker path
case $(uname -m) in
  x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;
esac

mkdir build && cd build

../configure \
    --target=$LFS_TGT \
    --prefix=/tools \
    --with-glibc-version=2.42 \
    --with-sysroot=/ \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++

make
make install DESTDIR=$DESTDIR

# Создать полный limits.h
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    $(dirname $($DESTDIR/tools/bin/$LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h
```

**Артефакт содержит:**
```
/tools/bin/$LFS_TGT-gcc
/tools/bin/$LFS_TGT-g++
/tools/lib/gcc/$LFS_TGT/15.2.0/libgcc.a
/tools/libexec/gcc/...
...
```

**`--with-newlib` + `--without-headers`**: Glibc ещё не существует. GCC собирается с минимальной libgcc, без runtime-библиотек.

**`--disable-shared`**: Внутренние библиотеки GCC линкуются статически, чтобы не зависеть от библиотек хоста.

### 1.3. linux-headers

**Зависимости:** host-image, src:linux-6.16.1
**Build script:**
```bash
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
mkdir -p $DESTDIR/usr
cp -rv usr/include $DESTDIR/usr/
```

**Артефакт содержит:** `/usr/include/linux/`, `/usr/include/asm/`, и т.д.

Только заголовочные файлы, никакой компиляции.

### 1.4. glibc

**Зависимости:** host-image + артефакты binutils-pass1 + gcc-pass1 + linux-headers, src:glibc-2.42
**Build script:**
```bash
# Симлинк для LSB compliance
case $(uname -m) in
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $DESTDIR/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $DESTDIR/lib64/ld-lsb-x86-64.so.3 ;;
esac

mkdir build && cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../scripts/config.guess) \
    --enable-kernel=4.19 \
    --with-headers=/usr/include \
    --disable-nscd \
    libc_cv_slibdir=/usr/lib

make
make install DESTDIR=$DESTDIR
```

**Артефакт содержит:**
```
/usr/lib/libc.so.6
/usr/lib/libm.so.6
/usr/lib/ld-linux-x86-64.so.2
/usr/lib/crt1.o, crti.o, crtn.o
/usr/include/stdio.h, stdlib.h, ...
...
```

**`--host=$LFS_TGT`**: Заставляет использовать кросс-компилятор `$LFS_TGT-gcc`.

**`--prefix=/usr`**: В финальной системе glibc будет в `/usr`. DESTDIR обеспечивает, что при сборке файлы попадут в артефакт, а не в реальный `/usr`.

**Важно:** Артефакт glibc содержит динамический линкер (`ld-linux-x86-64.so.2`). Это тот файл, на который будут указывать все ELF-бинарники целевой системы в поле `PT_INTERP`.

**Проверка (в build script):** После `make install` можно проверить, что кросс-компилятор находит новую glibc:
```bash
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
# Должно показать: /lib64/ld-linux-x86-64.so.2
```

### 1.5. libstdc++

**Зависимости:** host-image + артефакты binutils-pass1 + gcc-pass1 + linux-headers + glibc, src:gcc-15.2.0
**Build script:**
```bash
mkdir build && cd build

../libstdc++-v3/configure \
    --host=$LFS_TGT \
    --build=$(../config.guess) \
    --prefix=/usr \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make
make install DESTDIR=$DESTDIR
```

**Артефакт содержит:**
```
/usr/lib/libstdc++.so*
/tools/$LFS_TGT/include/c++/15.2.0/...
```

**`--with-gxx-include-dir=/tools/...`**: Заголовки C++ ставятся туда, где кросс-компилятор их найдёт (через sysroot).

### Создание cross-image

После сборки всех артефактов фазы 1 создаётся **cross-image**:

```dockerfile
FROM host-image
COPY binutils-pass1 /
COPY gcc-pass1 /
COPY linux-headers /
COPY glibc /
COPY libstdc++ /
```

Этот образ содержит хостовые инструменты **плюс** кросс-тулчейн в `/tools/` и целевые библиотеки в `/usr/`.

---

## Фаза 2: Кросс-компиляция временных утилит

### Среда сборки

Все пакеты собираются в **cross-image**. Компилятор — кросс-компилятор `$LFS_TGT-gcc` из `/tools/bin/`.

### Общий шаблон configure

Все пакеты этой фазы (кроме binutils-pass2 и gcc-pass2) используют одинаковый паттерн:

```bash
./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(build-aux/config.guess)
    # + пакето-специфичные опции

make
make install DESTDIR=$DESTDIR
```

**`--host=$LFS_TGT`** заставляет configure использовать кросс-компилятор.
**`--prefix=/usr`** + DESTDIR → артефакт содержит файлы относительно `/usr/`.
Все артефакты **линкуются** с целевой glibc.

### Список пакетов

Каждый артефакт — отдельный рецепт. Зависимости: cross-image + src.

| # | Пакет | Специфичные опции configure | Артефакт содержит |
|---|-------|-----------------------------|-------------------|
| 2.1 | M4-1.4.20 | — | `/usr/bin/m4` |
| 2.2 | Ncurses-6.5 | `--without-debug`, `--without-normal`, `--with-shared`, `--enable-widec`, `--without-ada`, плюс предварительная сборка `tic` для хоста | `/usr/lib/libncursesw.so*`, `/usr/bin/tic` и др. |
| 2.3 | Bash-5.3 | `--without-bash-malloc`, `bash_cv_strtold_broken=no` | `/usr/bin/bash` + симлинк `/bin/sh → /usr/bin/bash` |
| 2.4 | Coreutils-9.7 | `--enable-install-program=hostname`, `--enable-no-install-program=kill,uptime` | `/usr/bin/ls`, `/usr/bin/cp`, `/usr/sbin/chroot` и др. |
| 2.5 | Diffutils-3.12 | — | `/usr/bin/diff`, `/usr/bin/cmp` |
| 2.6 | File-5.46 | Предварительная нативная сборка `file` для хоста (нужен при кросс-компиляции) | `/usr/bin/file`, `/usr/lib/libmagic.so*` |
| 2.7 | Findutils-4.10.0 | — | `/usr/bin/find`, `/usr/bin/xargs` |
| 2.8 | Gawk-5.3.2 | — | `/usr/bin/gawk` |
| 2.9 | Grep-3.12 | — | `/usr/bin/grep` |
| 2.10 | Gzip-1.14 | — | `/usr/bin/gzip` |
| 2.11 | Make-4.4.1 | `--without-guile` | `/usr/bin/make` |
| 2.12 | Patch-2.8 | — | `/usr/bin/patch` |
| 2.13 | Sed-4.9 | — | `/usr/bin/sed` |
| 2.14 | Tar-1.35 | — | `/usr/bin/tar` |
| 2.15 | Xz-5.8.1 | — | `/usr/bin/xz`, `/usr/lib/liblzma.so*` |

### 2.16. binutils-pass2

**Зависимости:** cross-image, src:binutils-2.45
```bash
mkdir build && cd build

../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../config.guess) \
    --enable-shared \
    --disable-nls \
    --enable-64-bit-bfd \
    --enable-new-dtags \
    --enable-default-hash-style=gnu

make
make install DESTDIR=$DESTDIR
```

**Артефакт содержит:** `/usr/bin/as`, `/usr/bin/ld`, `/usr/bin/objdump` и т.д. — **нативные** инструменты для целевой системы.

### 2.17. gcc-pass2

**Зависимости:** cross-image, src:gcc-15.2.0, src:mpfr, src:gmp, src:mpc
```bash
tar -xf $SRC_MPFR && mv mpfr-* mpfr
tar -xf $SRC_GMP  && mv gmp-*  gmp
tar -xf $SRC_MPC  && mv mpc-*  mpc

case $(uname -m) in
  x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;
esac

mkdir build && cd build

../configure \
    --host=$LFS_TGT \
    --build=$(../config.guess) \
    --prefix=/usr \
    --with-build-sysroot=/ \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-multilib \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --enable-languages=c,c++

make
make install DESTDIR=$DESTDIR

# Симлинк cc → gcc
ln -sv gcc $DESTDIR/usr/bin/cc
```

**Артефакт содержит:** `/usr/bin/gcc`, `/usr/bin/g++`, `/usr/bin/cc`, `/usr/lib/libgcc_s.so*`, `/usr/lib/libstdc++.so*`

Это **нативный** компилятор: он сам будет работать на целевой системе.

### Создание temp-image (FROM scratch)

Это ключевой момент — **отрезание от хоста**.

```dockerfile
FROM scratch
COPY linux-headers /
COPY glibc /
COPY libstdc++ /
COPY m4 /
COPY ncurses /
COPY bash /
COPY coreutils /
COPY diffutils /
COPY file /
COPY findutils /
COPY gawk /
COPY grep /
COPY gzip /
COPY make /
COPY patch /
COPY sed /
COPY tar /
COPY xz /
COPY binutils-pass2 /
COPY gcc-pass2 /
ENV PATH=/usr/bin:/usr/sbin
```

Этот образ **не содержит ничего от хоста**. В нём есть только кросс-скомпилированные артефакты. Бинарники в нём линкуются с glibc из артефакта glibc, и динамический линкер — тоже из этого артефакта.

**Важно:** Нужно также создать базовую структуру каталогов (`/etc`, `/var`, `/tmp`, `/dev`, `/proc`, `/sys`) и необходимые файлы (`/etc/passwd`, `/etc/group`, `/etc/ld.so.conf`). Это можно оформить как отдельный артефакт `base-filesystem`.

---

## Фаза 3: Дополнительные временные инструменты (в чистом образе)

### Среда сборки

Все пакеты собираются в **temp-image**. Компилятор — нативный GCC из gcc-pass2.

### Общий шаблон

```bash
./configure --prefix=/usr
make
make install DESTDIR=$DESTDIR
```

Обычная нативная сборка, без `--host`, без кросс-компиляции.

### Список пакетов

| # | Пакет | Зачем нужен | Особенности |
|---|-------|-------------|-------------|
| 3.1 | Gettext-0.26 | Для сборки пакетов с i18n | Минимальная сборка: только `msgfmt`, `msgmerge`, `xgettext` |
| 3.2 | Bison-3.8.2 | Генератор парсеров | — |
| 3.3 | Perl-5.42.0 | Нужен configure-скриптам | Минимальная сборка |
| 3.4 | Python-3.13.7 | Нужен для Meson | Минимальная сборка |
| 3.5 | Texinfo-7.2 | Для `make install` многих пакетов | — |
| 3.6 | Util-linux-2.41.1 | libuuid, libblkid и др. | — |

### Создание build-image

```dockerfile
FROM temp-image
COPY gettext /
COPY bison /
COPY perl /
COPY python /
COPY texinfo /
COPY util-linux /
```

Или, если ты предпочитаешь не накапливать слои:

```dockerfile
FROM scratch
COPY <все артефакты из temp-image> /
COPY gettext /
COPY bison /
COPY perl /
COPY python /
COPY texinfo /
COPY util-linux /
```

---

## Фаза 4: Финальная система

### Среда сборки

Все пакеты собираются в **build-image** (или в образе, который дополняется по мере сборки — см. ниже).

### Нарастающая сборка

По мере сборки финальных пакетов, некоторые из них нужны для сборки последующих. Есть два варианта:

**Вариант 1: Единый build-image.** Все финальные пакеты собираются в build-image. Артефакты не устанавливаются в сборочный образ — только в DESTDIR. Работает, если build-image уже содержит всё необходимое (все build-зависимости уже есть из фаз 2–3).

**Вариант 2: Нарастающие образы.** После сборки glibc-final создаём build-image-2 = build-image + glibc-final. После сборки gcc-final — build-image-3 = build-image-2 + gcc-final. И так далее. Это точнее повторяет LFS, где каждый следующий пакет видит уже установленные предыдущие.

Вариант 2 рекомендуется, так как некоторые пакеты при configure обнаруживают библиотеки, установленные предыдущими пакетами, и включают дополнительную функциональность.

### Пакеты финальной системы

Пакеты перечислены в порядке сборки. Для каждого пакета зависимости — это build-image + все ранее собранные финальные артефакты.

#### 4.1–4.2. Данные (без компиляции)

| # | Пакет | Содержимое |
|---|-------|-----------|
| 4.1 | Man-pages-6.15 | `/usr/share/man/` |
| 4.2 | Iana-Etc-20250807 | `/etc/services`, `/etc/protocols` |

#### 4.3. Glibc-2.42 (финальная)

```bash
mkdir build && cd build
echo "rootsbindir=/usr/sbin" > configparms

../configure \
    --prefix=/usr \
    --disable-werror \
    --enable-kernel=4.19 \
    --enable-stack-protector=strong \
    --disable-nscd \
    libc_cv_slibdir=/usr/lib

make
make install DESTDIR=$DESTDIR
```

Плюс конфигурационные файлы: `nsswitch.conf`, locales, timezone data. Их можно оформить как часть этого артефакта или как отдельный артефакт `glibc-config`.

**После этого артефакта** рекомендуется создать новый сборочный образ, содержащий финальную glibc.

#### 4.4–4.8. Библиотеки сжатия

| # | Пакет |
|---|-------|
| 4.4 | Zlib-1.3.1 |
| 4.5 | Bzip2-1.0.8 |
| 4.6 | Xz-5.8.1 |
| 4.7 | Lz4-1.10.0 |
| 4.8 | Zstd-1.5.7 |

Стандартная нативная сборка: `--prefix=/usr`, `make`, `make install DESTDIR=$DESTDIR`.

#### 4.9–4.12. Утилиты и библиотеки

| # | Пакет |
|---|-------|
| 4.9 | File-5.46 |
| 4.10 | Readline-8.3 |
| 4.11 | M4-1.4.20 |
| 4.12 | Bc-7.0.3 |
| 4.13 | Flex-2.6.4 |

#### 4.14–4.16. Тестовая инфраструктура

| # | Пакет | Нужен для |
|---|-------|-----------|
| 4.14 | Tcl-8.6.16 | Тесты GCC |
| 4.15 | Expect-5.45.4 | Тесты GCC |
| 4.16 | DejaGNU-1.6.3 | Тесты GCC |

Могут быть опущены, если не нужны тесты.

#### 4.17–4.27. Тулчейн и системные библиотеки

| # | Пакет | Заметки |
|---|-------|---------|
| 4.17 | Pkgconf-2.5.1 | |
| 4.18 | Binutils-2.45 | Финальные as, ld |
| 4.19 | GMP-6.3.0 | Зависимость GCC |
| 4.20 | MPFR-4.2.2 | Зависимость GCC |
| 4.21 | MPC-1.3.1 | Зависимость GCC |
| 4.22 | Attr-2.5.2 | |
| 4.23 | Acl-2.3.2 | Зависит от Attr |
| 4.24 | Libcap-2.76 | |
| 4.25 | Libxcrypt-4.4.38 | |
| 4.26 | Shadow-4.18.0 | passwd, useradd |
| 4.27 | **GCC-15.2.0** | **Полная сборка**: все languages, все runtime-библиотеки |

**После GCC** рекомендуется обновить сборочный образ: финальный GCC + финальная Glibc + финальный Binutils = полноценный нативный тулчейн.

#### 4.28–4.79. Остальные пакеты

| # | Пакет | # | Пакет |
|---|-------|---|-------|
| 4.28 | Ncurses-6.5 | 4.54 | Ninja-1.13.1 |
| 4.29 | Sed-4.9 | 4.55 | Meson-1.8.3 |
| 4.30 | Psmisc-23.7 | 4.56 | Kmod-34.2 |
| 4.31 | Gettext-0.26 | 4.57 | Coreutils-9.7 |
| 4.32 | Bison-3.8.2 | 4.58 | Diffutils-3.12 |
| 4.33 | Grep-3.12 | 4.59 | Gawk-5.3.2 |
| 4.34 | Bash-5.3 | 4.60 | Findutils-4.10.0 |
| 4.35 | Libtool-2.5.4 | 4.61 | Groff-1.23.0 |
| 4.36 | GDBM-1.26 | 4.62 | GRUB-2.12 |
| 4.37 | Gperf-3.3 | 4.63 | Gzip-1.14 |
| 4.38 | Expat-2.7.1 | 4.64 | IPRoute2-6.16.0 |
| 4.39 | Inetutils-2.6 | 4.65 | Kbd-2.8.0 |
| 4.40 | Less-679 | 4.66 | Libpipeline-1.5.8 |
| 4.41 | Perl-5.42.0 | 4.67 | Make-4.4.1 |
| 4.42 | XML::Parser-2.47 | 4.68 | Patch-2.8 |
| 4.43 | Intltool-0.51.0 | 4.69 | Tar-1.35 |
| 4.44 | Autoconf-2.72 | 4.70 | Texinfo-7.2 |
| 4.45 | Automake-1.18.1 | 4.71 | Vim-9.1 |
| 4.46 | OpenSSL-3.5.2 | 4.72 | MarkupSafe-3.0.2 |
| 4.47 | Libelf-0.193 | 4.73 | Jinja2-3.1.6 |
| 4.48 | Libffi-3.5.2 | 4.74 | Systemd-257.8 |
| 4.49 | Python-3.13.7 | 4.75 | D-Bus-1.16.2 |
| 4.50 | Flit-Core-3.12.0 | 4.76 | Man-DB-2.13.1 |
| 4.51 | Packaging-25.0 | 4.77 | Procps-ng-4.0.5 |
| 4.52 | Wheel-0.46.1 | 4.78 | Util-linux-2.41.1 |
| 4.53 | Setuptools-80.9.0 | 4.79 | E2fsprogs-1.47.3 |

Все собираются с `--prefix=/usr` нативно.

### Создание final-image

```dockerfile
FROM scratch
COPY base-filesystem /
COPY man-pages /
COPY iana-etc /
COPY glibc-final /
COPY zlib /
COPY bzip2 /
# ... все остальные финальные артефакты ...
COPY e2fsprogs /
COPY linux-kernel /
```

---

## Фаза 5: Ядро и загрузчик

### 5.1. Linux-6.16.1

**Зависимости:** build-image (финальный), src:linux-6.16.1, src:kernel-config
```bash
make mrproper
cp $SRC_KERNEL_CONFIG .config
make
make modules_install DESTDIR=$DESTDIR
cp arch/x86/boot/bzImage $DESTDIR/boot/vmlinuz-6.16.1-lfs
cp System.map $DESTDIR/boot/System.map-6.16.1
```

---

## Граф зависимостей (ключевые узлы)

```
host-image ──┐
             ├──► binutils-pass1 ──┐
             ├──► gcc-pass1 ───────┤
             ├──► linux-headers ───┤
             │                     ├──► glibc ──┐
             │                     │            ├──► libstdc++ ──┐
             │                     │            │               │
             │                     ▼            ▼               ▼
             │                   cross-image ═══════════════════╡
             │                     │                            │
             │                     ├──► m4, bash, coreutils, ...│
             │                     ├──► binutils-pass2          │
             │                     └──► gcc-pass2               │
             │                                                  │
             │              temp-image (FROM scratch) ◄═════════╡
             │                     │                            │
             │                     ├──► gettext, bison, perl,...│
             │                     │                            │
             │              build-image ◄═══════════════════════╡
             │                     │                            │
             │                     ├──► glibc-final             │
             │                     ├──► gcc-final               │
             │                     ├──► ... (78 пакетов)        │
             │                     │                            │
             │              final-image (FROM scratch) ◄════════╛
```

---

## Количество образов и артефактов

| Тип | Количество |
|-----|-----------|
| Образы | 5–8 (host, cross, temp, build, build-upgraded × несколько, final) |
| Артефакты фаза 1 | 5 (binutils-p1, gcc-p1, linux-headers, glibc, libstdc++) |
| Артефакты фаза 2 | 17 (15 утилит + binutils-p2 + gcc-p2) |
| Артефакты фаза 3 | 6 |
| Артефакты фаза 4 | ~80 |
| Артефакты фаза 5 | 1 (ядро) |
| **Итого артефактов** | **~109** |
