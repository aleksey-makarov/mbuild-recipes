{
  "bison-3.8.2" = {
    type = "binary",
    inputs = ["bison-src-3.8.2", "buildscript-autotools"],
    outputs = ["bison-3.8.2"],
  },

  "bison-src-3.8.2" = {
    type = "fetch",
    outputs = ["bison-src-3.8.2"],
    url = [
      "https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz",
      "https://mirrors.kernel.org/gnu/bison/bison-3.8.2.tar.xz",
    ],
    hash = "md5:c28f119f405a2304ff0a7ccdcc629713",
  },
}
