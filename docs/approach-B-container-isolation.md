# Подход B: Bootstrap через контейнерную изоляцию (без кросс-компиляции)

## Обзор

Этот подход использует контейнерную изоляцию вместо кросс-компиляции. Идея: собираем glibc + gcc + binutils + утилиты **нативно** в начальном образе, создаём чистый `FROM scratch` образ из собранного, и в нём **пересобираем всё заново** — включая сами glibc, gcc и binutils. В результате финальная система не содержит ничего от хоста.

### Почему это работает

В LFS кросс-компиляция нужна для одной цели: **чтобы собранные пакеты не зависели от хоста**. Контейнеры дают другой путь к той же цели:

1. Собираем пакеты нативно внутри контейнера с хостовыми инструментами
2. Бинарники линкуются с хостовой glibc, но это не страшно — мы их выбросим
3. Создаём чистый `FROM scratch` образ из **наших** glibc + gcc + утилит
4. В чистом образе всё пересобираем — теперь бинарники линкуются с **нашей** glibc
5. Зависимость от хоста разорвана

### Сравнение с подходом A

| | Подход A (кросс) | Подход B (контейнеры) |
|---|---|---|
| Кросс-компиляция | Да (главы 5–6 LFS) | Нет |
| Количество сборок GCC | 3 (pass1, pass2, final) | 3 (temp, rebuild, final) |
| Сложность рецептов | Выше (--host, --target, кросс-workaround'ы) | Ниже (всё нативное) |
| Количество артефактов | ~109 | ~160 (из-за двойной пересборки) |
| Верность оригиналу LFS | Высокая | Средняя — другая стратегия |
| Feature detection | Может быть неточным при кросс-компиляции | Корректный (нативный configure) |

---

## Терминология

| Термин | Значение |
|--------|----------|
| **host-image** | Начальный образ с хостовым тулчейном |
| **bootstrap-image** | Чистый образ (FROM scratch) из нативно собранных пакетов — «поколение 1» |
| **rebuild-image** | bootstrap-image с пересобранным тулчейном — «поколение 2» |
| **final-image** | Чистый образ с финальной системой — «поколение 2» |

## Общая схема

```
host-image (Fedora/Debian с gcc)
    │
    │  Фаза 1: нативная сборка «поколения 1»
    │  (собранное линкуется с хостовой glibc, но это OK — оно временное)
    │
    ├── glibc-temp          ─┐
    ├── binutils-temp        │
    ├── gcc-temp             │
    ├── linux-headers        │
    ├── bash-temp            │ артефакты «поколения 1»
    ├── coreutils-temp       │
    ├── make-temp            │
    ├── ... (утилиты)        │
    ├── perl-temp            │
    ├── python-temp         ─┘
    │
    ▼
bootstrap-image = FROM scratch + все артефакты «поколения 1»
    │
    │  Фаза 2: пересборка в чистом окружении
    │  (теперь всё линкуется с нашей glibc)
    │
    ├── glibc-final         ─┐
    ├── binutils-final       │
    ├── gcc-final            │ артефакты «поколения 2» (финальные)
    ├── bash-final           │
    ├── ... (все 80 пакетов) │
    ├── systemd              │
    ├── linux-kernel        ─┘
    │
    ▼
final-image = FROM scratch + все финальные артефакты
```

---

## Фаза 1: Нативная сборка временных пакетов

### Среда сборки

Все пакеты собираются в **host-image** хостовым компилятором. Это обычная нативная сборка.

### Ключевое отличие от LFS

В LFS главы 5–6 используют кросс-компилятор. Здесь мы собираем **нативно хостовым gcc**. Собранные бинарники будут зависеть от хостовой glibc (через `PT_INTERP` и `DT_NEEDED`). **Это нормально** — они нужны только чтобы собрать «поколение 2», после чего будут выброшены.

### Проблема: бинарники линкуются с хостовой glibc

Если мы просто соберём bash с `--prefix=/usr` и `DESTDIR`, артефакт будет содержать `/usr/bin/bash`, но этот bash при запуске захочет `/lib64/ld-linux-x86-64.so.2` хоста. В `FROM scratch` образе он не запустится, если наша glibc лежит по другому пути.

**Решение:** Мы собираем **и glibc тоже**, с `--prefix=/usr`. Наша glibc установит ld-linux по тому же стандартному пути `/lib64/ld-linux-x86-64.so.2`. Но бинарники из host-image всё ещё линкуются с хостовой glibc, а не с нашей.

**Ключевой момент:** Нам нужно, чтобы в bootstrap-image бинарники использовали **нашу** glibc. Для этого есть два способа:

**Способ 1 (простой): Двойная сборка с пересборкой в bootstrap-image.**
Собираем всё нативно в host-image. Бинарники зависят от хоста. Копируем в `FROM scratch`. Бинарники не работают! Но у нас есть наша glibc и наш gcc **в исходниках**. Проблема: мы не можем их скомпилировать, если компилятор не запускается.

**Способ 2 (рабочий): Сборка с нашей glibc через явные пути.**
Собираем glibc и gcc первыми. Затем для всех остальных пакетов используем **наш gcc**, явно указывая пути к нашей glibc. Бинарники будут линковаться с нашей glibc.

**Способ 3 (самый простой, рекомендуемый): Сборка в обогащённом host-image.**
Собираем glibc → ставим в host-image поверх хостовой → собираем gcc → ставим поверх хостового → собираем всё остальное нашим gcc с нашей glibc. Бинарники сразу корректны.

Ниже описан **Способ 3**, как самый практичный.

### Стратегия: постепенная замена хостовых компонентов

```
host-image
    │
    ├─► собираем glibc-temp (хостовым gcc) ──► host-image-1 = host-image + glibc-temp
    │                                              │
    ├─► собираем binutils-temp (в host-image-1) ──► host-image-2 = host-image-1 + binutils-temp
    │                                                  │
    ├─► собираем gcc-temp (в host-image-2) ──► host-image-3 = host-image-2 + gcc-temp
    │                                              │
    │   (теперь host-image-3 содержит НАШИ glibc + binutils + gcc)
    │   (все последующие пакеты собираются нашим тулчейном)
    │                                              │
    ├─► собираем все утилиты в host-image-3 ──► артефакты «поколения 1»
    │
    ▼
bootstrap-image = FROM scratch + glibc-temp + binutils-temp + gcc-temp + все утилиты
```

### 1.1. linux-headers

**Зависимости:** host-image, src:linux-6.16.1
```bash
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
mkdir -p $DESTDIR/usr
cp -rv usr/include $DESTDIR/usr/
```

**Артефакт:** `/usr/include/linux/`, `/usr/include/asm/`, и т.д.

### 1.2. glibc-temp

**Зависимости:** host-image + linux-headers, src:glibc-2.42
```bash
mkdir build && cd build
echo "rootsbindir=/usr/sbin" > configparms

../configure \
    --prefix=/usr \
    --enable-kernel=4.19 \
    --enable-stack-protector=strong \
    --disable-nscd \
    --disable-werror \
    libc_cv_slibdir=/usr/lib

make
make install DESTDIR=$DESTDIR

# Симлинк для стандартного пути dynamic linker
mkdir -p $DESTDIR/lib64
ln -sfv ../usr/lib/ld-linux-x86-64.so.2 $DESTDIR/lib64/ld-linux-x86-64.so.2
```

**Артефакт:** `/usr/lib/libc.so.6`, `/usr/lib/ld-linux-x86-64.so.2`, заголовки, и т.д.

**Создание host-image-1:**
```dockerfile
FROM host-image
COPY linux-headers /
COPY glibc-temp /
# Пересоздать ldconfig cache
RUN ldconfig
```

Теперь хостовый gcc при линковке будет использовать **нашу** glibc (она перезаписала хостовую).

### 1.3. binutils-temp

**Зависимости:** host-image-1, src:binutils-2.45
```bash
mkdir build && cd build

../configure \
    --prefix=/usr \
    --enable-shared \
    --enable-64-bit-bfd \
    --enable-new-dtags \
    --enable-default-hash-style=gnu \
    --disable-nls \
    --disable-werror \
    --disable-gprofng

make
make install DESTDIR=$DESTDIR
```

**Создание host-image-2:**
```dockerfile
FROM host-image-1
COPY binutils-temp /
```

### 1.4. gcc-temp (с полными зависимостями)

**Зависимости:** host-image-2, src:gcc-15.2.0, src:gmp, src:mpfr, src:mpc

Сначала нужны GMP, MPFR, MPC. Их можно собрать как отдельные артефакты, или встроить в дерево GCC:

```bash
tar -xf $SRC_GMP  && mv gmp-*  gmp
tar -xf $SRC_MPFR && mv mpfr-* mpfr
tar -xf $SRC_MPC  && mv mpc-*  mpc

case $(uname -m) in
  x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;
esac

mkdir build && cd build

../configure \
    --prefix=/usr \
    --enable-languages=c,c++ \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-multilib \
    --disable-nls \
    --with-system-zlib

make
make install DESTDIR=$DESTDIR
ln -sv gcc $DESTDIR/usr/bin/cc
```

**Примечание:** Это почти полная сборка GCC. Можно отключить `--disable-libatomic --disable-libgomp` и т.д. для скорости, или собрать полностью — в любом случае это временный пакет.

**Создание host-image-3:**
```dockerfile
FROM host-image-2
COPY gcc-temp /
RUN ldconfig
```

Теперь в host-image-3 **наши** glibc, binutils, gcc. Всё, что мы соберём дальше, будет линковаться с нашей glibc нашим линкером.

### 1.5–1.20. Временные утилиты

Все собираются в **host-image-3** с нашим тулчейном. Стандартная нативная сборка:

```bash
./configure --prefix=/usr [пакето-специфичные опции]
make
make install DESTDIR=$DESTDIR
```

| # | Пакет | Зачем нужен в bootstrap-image |
|---|-------|-------------------------------|
| 1.5 | M4-1.4.20 | Для Bison, autoconf |
| 1.6 | Ncurses-6.5 | Для Bash, less |
| 1.7 | Bash-5.3 | Shell |
| 1.8 | Coreutils-9.7 | ls, cp, mv, mkdir, ... |
| 1.9 | Diffutils-3.12 | diff, cmp |
| 1.10 | File-5.46 | file, libmagic |
| 1.11 | Findutils-4.10.0 | find, xargs |
| 1.12 | Gawk-5.3.2 | awk |
| 1.13 | Grep-3.12 | grep |
| 1.14 | Gzip-1.14 | gzip, gunzip |
| 1.15 | Make-4.4.1 | make |
| 1.16 | Patch-2.8 | patch |
| 1.17 | Sed-4.9 | sed |
| 1.18 | Tar-1.35 | tar |
| 1.19 | Xz-5.8.1 | xz, liblzma |
| 1.20 | Gettext-0.26 | msgfmt, msgmerge |
| 1.21 | Bison-3.8.2 | yacc |
| 1.22 | Perl-5.42.0 | Для configure-скриптов |
| 1.23 | Python-3.13.7 | Для Meson |
| 1.24 | Texinfo-7.2 | makeinfo |
| 1.25 | Util-linux-2.41.1 | mount, libuuid, libblkid |
| 1.26 | Zlib-1.3.1 | libz (нужна многим) |
| 1.27 | Bzip2-1.0.8 | libbz2 |
| 1.28 | Pkgconf-2.5.1 | pkg-config |
| 1.29 | Flex-2.6.4 | lex |
| 1.30 | Bc-7.0.3 | Для скриптов ядра |

**Примечание:** Список шире, чем в LFS главах 6–7, потому что нет ограничений кросс-компиляции. Мы можем собрать всё, что нужно для комфортной сборочной среды.

### Создание bootstrap-image

Артефакт **base-filesystem** (отдельный рецепт):
```bash
# Создать структуру каталогов
mkdir -pv $DESTDIR/{etc,var,tmp,dev,proc,sys,run}
mkdir -pv $DESTDIR/usr/{bin,lib,sbin,share,include}
mkdir -pv $DESTDIR/var/{log,mail,spool}

# /bin, /sbin, /lib → симлинки на /usr/*
ln -sv usr/bin  $DESTDIR/bin
ln -sv usr/sbin $DESTDIR/sbin
ln -sv usr/lib  $DESTDIR/lib
ln -sv usr/lib  $DESTDIR/lib64  # для x86_64

# Минимальные конфигурационные файлы
cat > $DESTDIR/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/bin/false
EOF

cat > $DESTDIR/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
nobody:x:65534:
EOF

# ld.so.conf
cat > $DESTDIR/etc/ld.so.conf << "EOF"
/usr/lib
EOF
```

```dockerfile
FROM scratch
COPY base-filesystem /
COPY linux-headers /
COPY glibc-temp /
COPY binutils-temp /
COPY gcc-temp /
COPY m4-temp /
COPY ncurses-temp /
COPY bash-temp /
COPY coreutils-temp /
COPY diffutils-temp /
COPY file-temp /
COPY findutils-temp /
COPY gawk-temp /
COPY grep-temp /
COPY gzip-temp /
COPY make-temp /
COPY patch-temp /
COPY sed-temp /
COPY tar-temp /
COPY xz-temp /
COPY gettext-temp /
COPY bison-temp /
COPY perl-temp /
COPY python-temp /
COPY texinfo-temp /
COPY util-linux-temp /
COPY zlib-temp /
COPY bzip2-temp /
COPY pkgconf-temp /
COPY flex-temp /
COPY bc-temp /
RUN ldconfig
ENV PATH=/usr/bin:/usr/sbin
```

**Этот образ не содержит ничего от хоста.** Все бинарники в нём линкуются с glibc-temp, которая была собрана в host-image-1 нашим (уже заменённым) тулчейном.

**Проверка:** Все бинарники в bootstrap-image должны иметь `PT_INTERP: /lib64/ld-linux-x86-64.so.2` и `DT_NEEDED: libc.so.6` — и обе эти библиотеки должны быть из артефакта glibc-temp.

---

## Фаза 2: Финальная пересборка

### Зачем пересобирать

Пакеты «поколения 1» собраны в host-image, где присутствовали хостовые библиотеки. Даже после замены glibc/gcc, configure-скрипты могли обнаружить хостовые библиотеки (например, libssl хоста) и включить зависимости от них. Пересборка в чистом bootstrap-image гарантирует, что configure видит **только наши** пакеты.

Кроме того (как и в LFS глава 8): полная пересборка нужна для корректного feature detection, запуска тестов и получения стабильного результата.

### Среда сборки

Все пакеты собираются в **bootstrap-image** или в нарастающих образах (bootstrap-image + уже пересобранные пакеты).

### Стратегия нарастающих образов

Как и в подходе A, рекомендуется обновлять сборочный образ по мере пересборки ключевых пакетов:

```
bootstrap-image
    ├─► glibc-final     ──► build-image-1 = bootstrap-image + glibc-final
    ├─► binutils-final   ──► build-image-2 = build-image-1 + binutils-final
    ├─► gcc-final        ──► build-image-3 = build-image-2 + gcc-final
    │
    │   (build-image-3 = полностью пересобранный тулчейн)
    │
    ├─► все остальные пакеты (в build-image-3 или его обновлениях)
```

### Пакеты финальной системы

Порядок и содержание **идентичны** фазе 4 подхода A. Все собираются нативно с `--prefix=/usr`.

#### 2.1–2.2. Данные

| # | Пакет |
|---|-------|
| 2.1 | Man-pages-6.15 |
| 2.2 | Iana-Etc-20250807 |

#### 2.3. Glibc-2.42 (финальная)

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
# make check  # опционально
make install DESTDIR=$DESTDIR
```

Обновить сборочный образ после этого артефакта.

#### 2.4–2.8. Библиотеки сжатия

| # | Пакет |
|---|-------|
| 2.4 | Zlib-1.3.1 |
| 2.5 | Bzip2-1.0.8 |
| 2.6 | Xz-5.8.1 |
| 2.7 | Lz4-1.10.0 |
| 2.8 | Zstd-1.5.7 |

#### 2.9–2.13. Утилиты и библиотеки

| # | Пакет |
|---|-------|
| 2.9 | File-5.46 |
| 2.10 | Readline-8.3 |
| 2.11 | M4-1.4.20 |
| 2.12 | Bc-7.0.3 |
| 2.13 | Flex-2.6.4 |

#### 2.14–2.16. Тестовая инфраструктура (опциональна)

| # | Пакет |
|---|-------|
| 2.14 | Tcl-8.6.16 |
| 2.15 | Expect-5.45.4 |
| 2.16 | DejaGNU-1.6.3 |

#### 2.17–2.27. Тулчейн и системные библиотеки

| # | Пакет | Заметки |
|---|-------|---------|
| 2.17 | Pkgconf-2.5.1 | |
| 2.18 | Binutils-2.45 | Финальный. Обновить образ. |
| 2.19 | GMP-6.3.0 | |
| 2.20 | MPFR-4.2.2 | |
| 2.21 | MPC-1.3.1 | |
| 2.22 | Attr-2.5.2 | |
| 2.23 | Acl-2.3.2 | |
| 2.24 | Libcap-2.76 | |
| 2.25 | Libxcrypt-4.4.38 | |
| 2.26 | Shadow-4.18.0 | |
| 2.27 | **GCC-15.2.0** | **Полная сборка**. Обновить образ. |

#### 2.28–2.79. Все остальные пакеты

Полный список идентичен подходу A, пакеты 4.28–4.79. Все собираются нативно с `--prefix=/usr`.

| # | Пакет | # | Пакет |
|---|-------|---|-------|
| 2.28 | Ncurses-6.5 | 2.54 | Ninja-1.13.1 |
| 2.29 | Sed-4.9 | 2.55 | Meson-1.8.3 |
| 2.30 | Psmisc-23.7 | 2.56 | Kmod-34.2 |
| 2.31 | Gettext-0.26 | 2.57 | Coreutils-9.7 |
| 2.32 | Bison-3.8.2 | 2.58 | Diffutils-3.12 |
| 2.33 | Grep-3.12 | 2.59 | Gawk-5.3.2 |
| 2.34 | Bash-5.3 | 2.60 | Findutils-4.10.0 |
| 2.35 | Libtool-2.5.4 | 2.61 | Groff-1.23.0 |
| 2.36 | GDBM-1.26 | 2.62 | GRUB-2.12 |
| 2.37 | Gperf-3.3 | 2.63 | Gzip-1.14 |
| 2.38 | Expat-2.7.1 | 2.64 | IPRoute2-6.16.0 |
| 2.39 | Inetutils-2.6 | 2.65 | Kbd-2.8.0 |
| 2.40 | Less-679 | 2.66 | Libpipeline-1.5.8 |
| 2.41 | Perl-5.42.0 | 2.67 | Make-4.4.1 |
| 2.42 | XML::Parser-2.47 | 2.68 | Patch-2.8 |
| 2.43 | Intltool-0.51.0 | 2.69 | Tar-1.35 |
| 2.44 | Autoconf-2.72 | 2.70 | Texinfo-7.2 |
| 2.45 | Automake-1.18.1 | 2.71 | Vim-9.1 |
| 2.46 | OpenSSL-3.5.2 | 2.72 | MarkupSafe-3.0.2 |
| 2.47 | Libelf-0.193 | 2.73 | Jinja2-3.1.6 |
| 2.48 | Libffi-3.5.2 | 2.74 | Systemd-257.8 |
| 2.49 | Python-3.13.7 | 2.75 | D-Bus-1.16.2 |
| 2.50 | Flit-Core-3.12.0 | 2.76 | Man-DB-2.13.1 |
| 2.51 | Packaging-25.0 | 2.77 | Procps-ng-4.0.5 |
| 2.52 | Wheel-0.46.1 | 2.78 | Util-linux-2.41.1 |
| 2.53 | Setuptools-80.9.0 | 2.79 | E2fsprogs-1.47.3 |

#### 2.80. Linux-6.16.1

```bash
make mrproper
cp $SRC_KERNEL_CONFIG .config
make
make modules_install DESTDIR=$DESTDIR
cp arch/x86/boot/bzImage $DESTDIR/boot/vmlinuz-6.16.1-lfs
```

### Создание final-image

```dockerfile
FROM scratch
COPY base-filesystem /
COPY man-pages-final /
COPY iana-etc-final /
COPY glibc-final /
COPY zlib-final /
# ... все финальные артефакты ...
COPY e2fsprogs-final /
COPY linux-kernel /
RUN ldconfig
```

---

## Тонкий момент: линковка glibc-temp

Главный технический риск подхода B — момент замены хостовой glibc на нашу (шаг 1.2).

### Проблема

Когда мы устанавливаем glibc-temp поверх хостовой в host-image-1, хостовые бинарники (gcc, make, bash) начинают использовать **нашу** glibc. Если наша glibc несовместима с хостовыми бинарниками (например, собрана с другими флагами или другой версией ядра), всё может сломаться.

### Решение

На практике это работает, если:

1. **Наша glibc ≥ хостовой версии** — glibc поддерживает обратную совместимость через symbol versioning. Хостовые бинарники, собранные с glibc 2.38, будут работать с glibc 2.42.
2. **`--enable-kernel` не выше, чем ядро хоста** — мы используем `--enable-kernel=4.19`, что ниже любого современного хоста.
3. **Тот же ABI** — мы собираем для той же архитектуры (x86_64).

Если хостовая glibc **новее** нашей, могут быть проблемы. В этом случае нужно **не заменять** хостовую glibc, а установить нашу в отдельный prefix (например, `/opt/lfs/`) и настроить gcc на использование этого prefix. Это усложняет рецепты, но решает проблему. Альтернативный путь — использовать подход A.

---

## Граф зависимостей

```
host-image ──┐
             ├──► linux-headers ──────────────────────┐
             ├──► glibc-temp ─────► host-image-1 ─────┤
             │                          │              │
             │    binutils-temp ────► host-image-2 ────┤
             │                          │              │
             │    gcc-temp ─────────► host-image-3 ────┤
             │                          │              │
             │    m4, bash, coreutils, make, ...       │
             │    perl, python, texinfo, util-linux    │
             │    zlib, bzip2, pkgconf, flex, bc       │
             │                                         │
             │    bootstrap-image (FROM scratch) ◄═════╡
             │         │                               │
             │         ├──► glibc-final ──► build-1    │
             │         ├──► binutils-final ──► build-2 │
             │         ├──► gcc-final ──► build-3      │
             │         │                               │
             │         ├──► ... (78 пакетов)           │
             │         │                               │
             │    final-image (FROM scratch) ◄══════════╛
```

---

## Количество образов и артефактов

| Тип | Количество |
|-----|-----------|
| Образы | 6–10 (host, host-1, host-2, host-3, bootstrap, build-1, build-2, build-3, final) |
| Артефакты фаза 1 | ~32 (glibc-temp, gcc-temp, binutils-temp + 29 утилит) |
| Артефакты фаза 2 | ~80 (полная система) |
| Служебные артефакты | 1–2 (base-filesystem, kernel-config) |
| **Итого артефактов** | **~114** |

---

## Рекомендация

Подход B проще в реализации рецептов (нет `--host`, `--target`, `DESTDIR` + sysroot хитростей), но требует аккуратности с заменой хостовой glibc. Если начальный host-image основан на дистрибутиве с glibc ≤ 2.42 (что верно для большинства текущих дистрибутивов), подход B работает надёжно и рекомендуется как основной.

Если нужна поддержка произвольного хоста (включая очень новые дистрибутивы с glibc > 2.42) или 100% верность процессу LFS — используйте подход A.
