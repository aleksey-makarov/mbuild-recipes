{
  "iproute2-6.16.0" = {
    type = "binary",
    inputs = ["iproute2-src-6.16.0", "buildscript-gnu-make", "bootstrap-binary-image"],
    outputs = ["iproute2-6.16.0"],
  },

  "iproute2-src-6.16.0" = {
    type = "fetch",
    outputs = ["iproute2-src-6.16.0"],
    url = "https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.16.0.tar.xz",
    hash = "md5:80e1f91bf59d572acc15d5c6eb4f3e7c",
  },
}
