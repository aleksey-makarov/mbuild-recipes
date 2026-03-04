{
  "sed-4.9" = {
    type = "binary",
    inputs = ["sed-src-4.9", "buildscript-autotools"],
    outputs = ["sed-4.9"],
  },
  "sed-src-4.9" = {
    type = "fetch",
    outputs = ["sed-src-4.9"],
    url = [
      "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz",
      "https://mirrors.kernel.org/gnu/sed/sed-4.9.tar.xz",
    ],
    hash = "md5:6aac9b2dbafcd5b7a67a8a9bcb8036c3",
  },
}
