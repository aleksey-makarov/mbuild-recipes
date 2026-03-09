{
  "dejagnu-1.6.3" = {
    type = "binary",
    inputs = ["dejagnu-src-1.6.3", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["dejagnu-1.6.3"],
  },

  "dejagnu-src-1.6.3" = {
    type = "fetch",
    outputs = ["dejagnu-src-1.6.3"],
    url = [
      "https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz",
      "https://mirrors.kernel.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz",
    ],
    hash = "md5:68c5208c58236eba447d7d6d1326b821",
  },
}
