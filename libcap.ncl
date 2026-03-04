{
  "libcap-2.76" = {
    type = "binary",
    inputs = ["libcap-src-2.76", "buildscript-gnu-make"],
    outputs = ["libcap-2.76"],
  },
  "libcap-src-2.76" = {
    type = "fetch",
    outputs = ["libcap-src-2.76"],
    url = "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.76.tar.xz",
    hash = "md5:449ade7d620b5c4eeb15a632fbaa4f74",
  },
}
