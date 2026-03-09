{
  "groff-1.23.0" = {
    type = "binary",
    inputs = ["groff-src-1.23.0", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["groff-1.23.0"],
  },

  "groff-src-1.23.0" = {
    type = "fetch",
    outputs = ["groff-src-1.23.0"],
    url = [
      "https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz",
      "https://mirrors.kernel.org/gnu/groff/groff-1.23.0.tar.gz",
    ],
    hash = "md5:5e4f40315a22bb8a158748e7d5094c7d",
  },
}
