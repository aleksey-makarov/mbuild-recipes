{
  "glibc-pass1-2.42" = {
    type = "binary",
    inputs = [
      "glibc-src-2.42",
      "glibc-fhs-patch-2.42",
      "buildscript-glibc-pass1-2.42",
      "bootstrap-for-glibc-pass1-2.42",
    ],
    outputs = ["glibc-pass1-2.42"],
  },

  "buildscript-glibc-pass1-2.42" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-glibc-pass1-2.42"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      cd "/in/${src}"

      if [ ! -x ./configure ]; then
        candidates=()
        for d in ./*; do
          if [ -d "$d" ] && [ -x "$d/configure" ]; then
            candidates+=("$d")
          fi
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          cd "${candidates[0]}"
        fi
      fi

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      patch -Np1 -i /in/glibc-fhs-patch-2.42
      mkdir -p build
      cd build

      echo "rootsbindir=/usr/sbin" > configparms

      CC="x86_64-lfs-linux-gnu-gcc --sysroot=/bootstrap-root" \
      CXX="x86_64-lfs-linux-gnu-g++ --sysroot=/bootstrap-root" \
      ../configure                               \
        --prefix=/usr                            \
        --host=x86_64-lfs-linux-gnu             \
        --build="$(../scripts/config.guess)"    \
        --disable-nscd                           \
        --with-headers=/bootstrap-root/usr/include \
        --with-binutils=/bootstrap-root/tools/bin \
        libc_cv_slibdir=/usr/lib                 \
        --enable-kernel=5.4

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "glibc-fhs-patch-2.42" = {
    type = "fetch",
    unpack = false,
    outputs = ["glibc-fhs-patch-2.42"],
    url = "https://www.linuxfromscratch.org/patches/lfs/12.4/glibc-2.42-fhs-1.patch",
    hash = "md5:9a5997c3452909b1769918c759eff8a2",
  },

  "glibc-src-2.42" = {
    type = "fetch",
    outputs = ["glibc-src-2.42"],
    url = [
      "https://ftp.gnu.org/gnu/glibc/glibc-2.42.tar.xz",
      "https://mirrors.kernel.org/gnu/glibc/glibc-2.42.tar.xz",
    ],
    hash = "md5:23c6f5a27932b435cae94e087cb8b1f5",
  },
}
