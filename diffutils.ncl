{
  "diffutils-3.12" = {
    type = "binary",
    inputs = ["diffutils-src-3.12", "buildscript-autotools"],
    outputs = ["diffutils-3.12"],
  },

  "diffutils-src-3.12" = {
    type = "fetch",
    outputs = ["diffutils-src-3.12"],
    url = [
      "https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz",
      "https://mirrors.kernel.org/gnu/diffutils/diffutils-3.12.tar.xz",
    ],
    hash = "md5:d1b18b20868fb561f77861cd90b05de4",
  },
}
