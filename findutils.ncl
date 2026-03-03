{
  "findutils-4.10.0" = {
    type = "binary",
    inputs = ["findutils-src-4.10.0", "buildscript-autotools"],
    outputs = ["findutils-4.10.0"],
  },

  "findutils-src-4.10.0" = {
    type = "fetch",
    outputs = ["findutils-src-4.10.0"],
    url = [
      "https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz",
      "https://mirrors.kernel.org/gnu/findutils/findutils-4.10.0.tar.xz",
    ],
    hash = "md5:870cfd71c07d37ebe56f9f4aaf4ad872",
  },
}
