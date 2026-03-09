{
  "procps-4.0.5" = {
    type = "binary",
    status = "source fetch failed: sourceforge URL returns hash-mismatched payload",
    inputs = ["procps-src-4.0.5", "buildscript-meson", "bootstrap-binary-image"],
    outputs = ["procps-4.0.5"],
  },
  "procps-src-4.0.5" = {
    type = "fetch",
    outputs = ["procps-src-4.0.5"],
    url = "https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-4.0.5.tar.xz",
    hash = "md5:90803e64f51f192f3325d25c3335d057",
  },
}
