{
  "kbd-2.8.0" = {
    type = "binary",
    status = "build failed: configure requires libpam-devel/pam headers in build image",
    inputs = ["kbd-src-2.8.0", "buildscript-autotools"],
    outputs = ["kbd-2.8.0"],
  },
  "kbd-src-2.8.0" = {
    type = "fetch",
    outputs = ["kbd-src-2.8.0"],
    url = "https://www.kernel.org/pub/linux/utils/kbd/kbd-2.8.0.tar.xz",
    hash = "md5:24b5d24f7483726b88f214dc6c77aa41",
  },
}
