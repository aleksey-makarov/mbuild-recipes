{
  "texinfo-7.2" = {
    type = "binary",
    inputs = ["texinfo-src-7.2", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["texinfo-7.2"],
  },
  "texinfo-src-7.2" = {
    type = "fetch",
    outputs = ["texinfo-src-7.2"],
    url = [
      "https://ftp.gnu.org/gnu/texinfo/texinfo-7.2.tar.xz",
      "https://mirrors.kernel.org/gnu/texinfo/texinfo-7.2.tar.xz",
    ],
    hash = "md5:11939a7624572814912a18e76c8d8972",
  },
}
