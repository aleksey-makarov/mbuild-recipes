{
  "gmp-6.3.0" = {
    type = "binary",
    inputs = ["gmp-src-6.3.0", "buildscript-autotools"],
    outputs = ["gmp-6.3.0"],
  },

  "gmp-src-6.3.0" = {
    type = "fetch",
    outputs = ["gmp-src-6.3.0"],
    url = [
      "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz",
      "https://mirrors.kernel.org/gnu/gmp/gmp-6.3.0.tar.xz",
    ],
    hash = "md5:956dc04e864001a9c22429f761f2c283",
  },
}
