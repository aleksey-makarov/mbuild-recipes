{
  "gzip-pass1-1.14" = {
    type = "binary",
    inputs = ["gzip-src-1.14", "buildscript-autotools-pass1", "bootstrap-pass1"],
    outputs = ["gzip-pass1-1.14"],
  },

  "gzip-src-1.14" = {
    type = "fetch",
    outputs = ["gzip-src-1.14"],
    url = [
      "https://ftp.gnu.org/gnu/gzip/gzip-1.14.tar.xz",
      "https://mirrors.kernel.org/gnu/gzip/gzip-1.14.tar.xz",
    ],
    hash = "md5:4bf5a10f287501ee8e8ebe00ef62b2c2",
  },
}
