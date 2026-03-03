{
  "file-5.46" = {
    type = "binary",
    inputs = ["file-src-5.46", "buildscript-autotools"],
    outputs = ["file-5.46"],
  },

  "file-src-5.46" = {
    type = "fetch",
    outputs = ["file-src-5.46"],
    url = "https://astron.com/pub/file/file-5.46.tar.gz",
    hash = "md5:459da2d4b534801e2e2861611d823864",
  },
}
