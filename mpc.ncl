{
  "buildscript-autotools-mpc-pass1-1.3.1" =
    (import "build/autotools.ncl").autotools {
      output = "buildscript-autotools-mpc-pass1-1.3.1",
      install = "make DESTDIR=\"/out/${out}/bootstrap-root\"",
      install_args = ["install"],
      configure_args = [
        "--with-mpfr=/bootstrap-root/usr",
        "--with-gmp=/bootstrap-root/usr",
      ],
    },

  "bootstrap-with-mpfr-image-4.2.2" = {
    type = "image",
    inputs = ["bootstrap-binary-image", "mpfr-pass1-4.2.2"],
    outputs = ["bootstrap-with-mpfr-image-4.2.2"],
  },

  "mpc-pass1-1.3.1" = {
    type = "binary",
    inputs = [
      "mpc-src-1.3.1",
      "buildscript-autotools-mpc-pass1-1.3.1",
      "bootstrap-with-mpfr-image-4.2.2",
    ],
    outputs = ["mpc-pass1-1.3.1"],
  },

  "mpc-src-1.3.1" = {
    type = "fetch",
    outputs = ["mpc-src-1.3.1"],
    url = [
      "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz",
      "https://mirrors.kernel.org/gnu/mpc/mpc-1.3.1.tar.gz",
    ],
    hash = "md5:5c9bc658c9fd0f940e8e3e0f09530c62",
  },
}
