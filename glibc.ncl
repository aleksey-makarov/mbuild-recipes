{
  "bootstrap-for-glibc-pass1-2.42" = {
    type = "image",
    inputs = [
      "bootstrap-binary-image",
      "binutils-pass1-2.45",
      "gcc-pass1-15.2.0",
      "linux-api-headers-6.18.10",
      "bison-3.8.2",
      "gawk-5.3.2",
    ],
    outputs = ["bootstrap-for-glibc-pass1-2.42"],
  },

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

      patch -Np1 -i /in/glibc-fhs-patch-2.42
      mkdir -p build
      cd build

      echo "rootsbindir=/usr/sbin" > configparms

      ../configure                             \
        --prefix=/usr                          \
        --host=x86_64-lfs-linux-gnu           \
        --build="$(../scripts/config.guess)"   \
        --disable-nscd                         \
        libc_cv_slibdir=/usr/lib               \
        --enable-kernel=5.4

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}" install

      case $(uname -m) in
        i?86)
          mkdir -p "/out/${out}/lib"
          ln -sfv ld-linux.so.2 "/out/${out}/lib/ld-lsb.so.3"
          ;;
        x86_64)
          mkdir -p "/out/${out}/lib64"
          ln -sfv ../lib/ld-linux-x86-64.so.2 "/out/${out}/lib64"
          ln -sfv ../lib/ld-linux-x86-64.so.2 "/out/${out}/lib64/ld-lsb-x86-64.so.3"
          ;;
      esac
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
