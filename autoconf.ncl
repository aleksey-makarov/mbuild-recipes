{
  "autoconf-2.72" = {
    type = "binary",
    inputs = ["autoconf-src-2.72", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["autoconf-2.72"],
  },

  "autoconf-src-2.72" = {
    type = "fetch",
    outputs = ["autoconf-src-2.72"],
    url = [
      "https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz",
      "https://mirrors.kernel.org/gnu/autoconf/autoconf-2.72.tar.xz",
    ],
    hash = "md5:1be79f7106ab6767f18391c5e22be701",
  },
}
