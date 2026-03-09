{
  "grep-3.12" = {
    type = "binary",
    inputs = ["grep-src-3.12", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["grep-3.12"],
  },

  "grep-src-3.12" = {
    type = "fetch",
    outputs = ["grep-src-3.12"],
    url = [
      "https://ftp.gnu.org/gnu/grep/grep-3.12.tar.xz",
      "https://mirrors.kernel.org/gnu/grep/grep-3.12.tar.xz",
    ],
    hash = "md5:5d9301ed9d209c4a88c8d3a6fd08b9ac",
  },
}
