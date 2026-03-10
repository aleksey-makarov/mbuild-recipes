{
  "buildscript-libstdcxx-pass1-15.2.0" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-libstdcxx-pass1-15.2.0"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      cd "/in/${src}"

      if [ ! -x ./config.guess ]; then
        candidates=()
        for d in ./*; do
          if [ -d "$d" ] && [ -x "$d/config.guess" ]; then
            candidates+=("$d")
          fi
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          cd "${candidates[0]}"
        fi
      fi

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      mkdir -p build
      cd build

      ../libstdc++-v3/configure      \
        --host=x86_64-lfs-linux-gnu  \
        --build="$(../config.guess)" \
        --prefix=/usr                \
        --disable-multilib           \
        --disable-nls                \
        --disable-libstdcxx-pch      \
        --with-gxx-include-dir=/tools/x86_64-lfs-linux-gnu/include/c++/15.2.0

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install

      rm -fv \
        "/out/${out}/bootstrap-root/usr/lib/libstdc++.la" \
        "/out/${out}/bootstrap-root/usr/lib/libstdc++exp.la" \
        "/out/${out}/bootstrap-root/usr/lib/libstdc++fs.la" \
        "/out/${out}/bootstrap-root/usr/lib/libsupc++.la"
      "%,
  },

  "bootstrap-for-libstdcxx-pass1-15.2.0" = {
    type = "image",
    inputs = ["bootstrap-for-glibc-pass1-2.42", "glibc-pass1-2.42"],
    outputs = ["bootstrap-for-libstdcxx-pass1-15.2.0"],
  },

  "libstdcxx-pass1-15.2.0" = {
    type = "binary",
    inputs = [
      "gcc-src-15.2.0",
      "buildscript-libstdcxx-pass1-15.2.0",
      "bootstrap-for-libstdcxx-pass1-15.2.0",
    ],
    outputs = ["libstdcxx-pass1-15.2.0"],
  },

  "buildscript-gcc-pass1-15.2.0" =
    (import "build/autotools.ncl").autotools {
      output = "buildscript-gcc-pass1-15.2.0",
      prefix = "/bootstrap-root/tools",
      in_source = false,
      prepend_path = ["/bootstrap-root/tools/bin"],
      configure_args = [
        "--target=x86_64-lfs-linux-gnu",
        "--with-glibc-version=2.42",
        "--with-sysroot=/bootstrap-root",
        "--with-newlib",
        "--without-headers",
        "--with-gmp=/usr",
        "--with-mpfr=/usr",
        "--with-mpc=/usr",
        "--enable-default-pie",
        "--enable-default-ssp",
        "--disable-nls",
        "--disable-shared",
        "--disable-multilib",
        "--disable-threads",
        "--disable-libatomic",
        "--disable-libgomp",
        "--disable-libquadmath",
        "--disable-libssp",
        "--disable-libvtv",
        "--disable-libstdcxx",
        "--enable-languages=c,c++",
      ],
      pre_configure = m%"
        case $(uname -m) in
          x86_64)
            sed -e '/m64=/s/lib64/lib/' -i gcc/config/i386/t-linux64
            ;;
        esac
        "%,
      post_install = m%"
        cat ../gcc/limitx.h ../gcc/glimits.h ../gcc/limity.h > \
          "$(dirname "$(/out/${out}/bootstrap-root/tools/bin/x86_64-lfs-linux-gnu-gcc -print-libgcc-file-name)")/include/limits.h"
        "%,
    },

  "bootstrap-with-binutils-gmp-mpfr-mpc-image-2.45-6.3.0-4.2.2-1.3.1" = {
    type = "image",
    inputs = [
      "bootstrap-binary-image",
      "binutils-pass1-2.45",
      "gmp-6.3.0",
      "mpfr-4.2.2",
      "mpc-1.3.1",
    ],
    outputs = ["bootstrap-with-binutils-gmp-mpfr-mpc-image-2.45-6.3.0-4.2.2-1.3.1"],
  },

  "gcc-pass1-15.2.0" = {
    type = "binary",
    inputs = [
      "gcc-src-15.2.0",
      "buildscript-gcc-pass1-15.2.0",
      "bootstrap-with-binutils-gmp-mpfr-mpc-image-2.45-6.3.0-4.2.2-1.3.1",
    ],
    outputs = ["gcc-pass1-15.2.0"],
  },

  "gcc-src-15.2.0" = {
    type = "fetch",
    outputs = ["gcc-src-15.2.0"],
    url = [
      "https://ftp.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz",
      "https://mirrors.kernel.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz",
    ],
    hash = "md5:b861b092bf1af683c46a8aa2e689a6fd",
  },
}
