{
  "libtool-2.5.4" = {
    type = "binary",
    inputs = ["libtool-src-2.5.4", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["libtool-2.5.4"],
  },
  "libtool-src-2.5.4" = {
    type = "fetch",
    outputs = ["libtool-src-2.5.4"],
    url = [
      "https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.xz",
      "https://mirrors.kernel.org/gnu/libtool/libtool-2.5.4.tar.xz",
    ],
    hash = "md5:22e0a29df8af5fdde276ea3a7d351d30",
  },
}
