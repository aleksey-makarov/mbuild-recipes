{
  "e2fsprogs-1.47.3" = {
    type = "binary",
    status = "missing dedicated buildscript config: install tries to write /etc/cron.d on container root",
    inputs = ["e2fsprogs-src-1.47.3", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["e2fsprogs-1.47.3"],
  },

  "e2fsprogs-src-1.47.3" = {
    type = "fetch",
    outputs = ["e2fsprogs-src-1.47.3"],
    url = "https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.3/e2fsprogs-1.47.3.tar.gz",
    hash = "md5:113d7a7ee0710d2a670a44692a35fd2e",
  },
}
