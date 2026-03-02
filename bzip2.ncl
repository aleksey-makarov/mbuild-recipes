{
  "bzip2-1.0.8" = {
    type = "binary",
    inputs = ["bzip2-src-1.0.8", "buildscript-gnu-make"],
    outputs = ["bzip2-1.0.8"],
  },

  "bzip2-src-1.0.8" = {
    type = "fetch",
    outputs = ["bzip2-src-1.0.8"],
    url = "https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz",
    hash = "md5:67e051268d0c475ea773822f7500d0e5",
  },
}
