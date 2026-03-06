{
  "buildscript-gcc-pass1-15.2.0" =
    (import "build/autotools.ncl").autotools {
      output = "buildscript-gcc-pass1-15.2.0",
      in_source = false,
      prepend_path = ["/in/binutils-pass1-2.45/tools/bin"],
      configure_args = [
        "--target=x86_64-lfs-linux-gnu",
        "--prefix=/out/gcc-pass1-15.2.0/tools",
        "--with-glibc-version=2.42",
        "--with-sysroot=/out/gcc-pass1-15.2.0",
        "--with-newlib",
        "--without-headers",
        "--with-gmp=/in/gmp-6.3.0",
        "--with-mpfr=/in/mpfr-4.2.2",
        "--with-mpc=/in/mpc-1.3.1",
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
      pre_configure =
        m%"
        case $(uname -m) in
          x86_64)
            sed -e '/m64=/s/lib64/lib/' -i gcc/config/i386/t-linux64
            ;;
        esac
        "%,
      post_install =
        m%"
        cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
          "$(dirname "$(/out/gcc-pass1-15.2.0/tools/bin/x86_64-lfs-linux-gnu-gcc -print-libgcc-file-name)")/include/limits.h"
        "%,
    },

  "gcc-pass1-15.2.0" = {
    type = "binary",
    inputs = [
      "gcc-src-15.2.0",
      "binutils-pass1-2.45",
      "gmp-6.3.0",
      "mpfr-4.2.2",
      "mpc-1.3.1",
      "buildscript-gcc-pass1-15.2.0",
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
