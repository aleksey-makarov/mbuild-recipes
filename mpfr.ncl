{
  "mpfr-pass1-4.2.2" = {
    type = "binary",
    inputs = [
      "mpfr-src-4.2.2",
      "buildscript-autotools-bootstrap-root",
      "bootstrap-binary-image",
    ],
    outputs = ["mpfr-pass1-4.2.2"],
  },

  "mpfr-src-4.2.2" = {
    type = "fetch",
    outputs = ["mpfr-src-4.2.2"],
    url = [
      "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz",
      "https://mirrors.kernel.org/gnu/mpfr/mpfr-4.2.2.tar.xz",
    ],
    hash = "md5:7c32c39b8b6e3ae85f25156228156061",
  },
}
