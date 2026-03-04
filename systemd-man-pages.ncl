{
  "systemd-man-pages-257.8" = {
    type = "binary",
    status = "docs package; no generic docs/install buildscript yet",
    inputs = ["systemd-man-pages-src-257.8"],
    outputs = ["systemd-man-pages-257.8"],
  },
  "systemd-man-pages-src-257.8" = {
    type = "fetch",
    outputs = ["systemd-man-pages-src-257.8"],
    url = "https://anduin.linuxfromscratch.org/LFS/systemd-man-pages-257.8.tar.xz",
    hash = "md5:a44063e2ec0cf4adfd2ed5c9e9e095c5",
  },
}
