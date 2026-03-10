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
        "--with-gmp=/bootstrap-root/usr",
        "--with-mpfr=/bootstrap-root/usr",
        "--with-mpc=/bootstrap-root/usr",
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

  "gcc-pass1-15.2.0" = {
    type = "binary",
    inputs = [
      "gcc-src-15.2.0",
      "buildscript-gcc-pass1-15.2.0",
      "bootstrap-for-gcc-pass1-15.2.0",
    ],
    outputs = ["gcc-pass1-15.2.0"],
  },

  "buildscript-gcc-pass2-15.2.0" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-gcc-pass2-15.2.0"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      gcc_root="/in/${src}"
      gmp_root="/in/gmp-src-6.3.0"
      mpfr_root="/in/mpfr-src-4.2.2"
      mpc_root="/in/mpc-src-1.3.1"

      detect_src_dir() {
        local root="$1"
        local entry
        local -a candidates=()
        for entry in "$root"/*; do
          [ -d "$entry" ] || continue
          candidates+=("$entry")
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          printf '%s\n' "${candidates[0]}"
        else
          printf '%s\n' "$root"
        fi
      }

      gcc_dir="$(detect_src_dir "${gcc_root}")"
      gmp_dir="$(detect_src_dir "${gmp_root}")"
      mpfr_dir="$(detect_src_dir "${mpfr_root}")"
      mpc_dir="$(detect_src_dir "${mpc_root}")"

      cd "${gcc_dir}"

      rm -rf gmp mpfr mpc
      cp -a "${gmp_dir}" gmp
      cp -a "${mpfr_dir}" mpfr
      cp -a "${mpc_dir}" mpc

      case $(uname -m) in
        x86_64)
          sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
          ;;
      esac

      sed '/thread_header =/s/@.*@/gthr-posix.h/' \
        -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

      unset CFLAGS
      unset CXXFLAGS

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      mkdir -p build
      cd build

      ../configure                   \
        --build="$(../config.guess)" \
        --host=x86_64-lfs-linux-gnu  \
        --target=x86_64-lfs-linux-gnu \
        --prefix=/usr                \
        --with-build-sysroot=/bootstrap-root \
        --enable-default-pie         \
        --enable-default-ssp         \
        --disable-nls                \
        --disable-multilib           \
        --disable-libatomic          \
        --disable-libgomp            \
        --disable-libquadmath        \
        --disable-libsanitizer       \
        --disable-libssp             \
        --disable-libvtv             \
        --enable-languages=c,c++     \
        LDFLAGS_FOR_TARGET="-L$PWD/x86_64-lfs-linux-gnu/libgcc"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install

      ln -svf gcc "/out/${out}/bootstrap-root/usr/bin/cc"
      "%,
  },

  "gcc-pass2-15.2.0" = {
    type = "binary",
    inputs = [
      "gcc-src-15.2.0",
      "gmp-src-6.3.0",
      "mpfr-src-4.2.2",
      "mpc-src-1.3.1",
      "buildscript-gcc-pass2-15.2.0",
      "bootstrap-for-gcc-pass2-15.2.0",
    ],
    outputs = ["gcc-pass2-15.2.0"],
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
