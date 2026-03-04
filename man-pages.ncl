{
  "man-pages-6.15" = {
    type = "binary",
    status = "docs package; no generic docs/install buildscript yet",
    inputs = ["man-pages-src-6.15"],
    outputs = ["man-pages-6.15"],
  },
  "man-pages-src-6.15" = {
    type = "fetch",
    outputs = ["man-pages-src-6.15"],
    url = "https://www.kernel.org/pub/linux/docs/man-pages/man-pages-6.15.tar.xz",
    hash = "md5:16f68d70139dd2bbcae4102be4705753",
  },
}
