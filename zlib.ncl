{
  "zlib-1.3.1" = {
    type = "binary",
    inputs = ["zlib-src-1.3.1", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["zlib-1.3.1"],
  },
  "zlib-src-1.3.1" = {
    type = "fetch",
    outputs = ["zlib-src-1.3.1"],
    url = "https://zlib.net/fossils/zlib-1.3.1.tar.gz",
    hash = "md5:9855b6d802d7fe5b7bd5b196a2271655",
  },
}
