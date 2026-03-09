{
  "gperf-3.3" = {
    type = "binary",
    inputs = ["gperf-src-3.3", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["gperf-3.3"],
  },

  "gperf-src-3.3" = {
    type = "fetch",
    outputs = ["gperf-src-3.3"],
    url = [
      "https://ftp.gnu.org/gnu/gperf/gperf-3.3.tar.gz",
      "https://mirrors.kernel.org/gnu/gperf/gperf-3.3.tar.gz",
    ],
    hash = "md5:31753b021ea78a21f154bf9eecb8b079",
  },
}
