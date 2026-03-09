{
  "inetutils-2.6" = {
    type = "binary",
    inputs = ["inetutils-src-2.6", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["inetutils-2.6"],
  },

  "inetutils-src-2.6" = {
    type = "fetch",
    outputs = ["inetutils-src-2.6"],
    url = [
      "https://ftp.gnu.org/gnu/inetutils/inetutils-2.6.tar.xz",
      "https://mirrors.kernel.org/gnu/inetutils/inetutils-2.6.tar.xz",
    ],
    hash = "md5:401d7d07682a193960bcdecafd03de94",
  },
}
