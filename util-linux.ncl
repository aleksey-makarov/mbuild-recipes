{
  "util-linux-2.41.1" = {
    type = "binary",
    status = "build failed: install hook runs chgrp on /out/bin/wall (operation not permitted in container)",
    inputs = ["util-linux-src-2.41.1", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["util-linux-2.41.1"],
  },
  "util-linux-src-2.41.1" = {
    type = "fetch",
    outputs = ["util-linux-src-2.41.1"],
    url = "https://www.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.1.tar.xz",
    hash = "md5:7e5e68845e2f347cf96f5448165f1764",
  },
}
