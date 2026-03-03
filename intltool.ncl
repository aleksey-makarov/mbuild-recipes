{
  "intltool-0.51.0" = {
    type = "binary",
    status = "configure requires perl XML::Parser module (missing in build image)",
    inputs = ["intltool-src-0.51.0", "buildscript-autotools"],
    outputs = ["intltool-0.51.0"],
  },

  "intltool-src-0.51.0" = {
    type = "fetch",
    outputs = ["intltool-src-0.51.0"],
    url = "https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz",
    hash = "md5:12e517cac2b57a0121cda351570f1e63",
  },
}
