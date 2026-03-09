{
  "mpc-1.3.1" = {
    type = "binary",
    status = "build failed: configure cannot find libmpfr (needs mpfr dependency wiring)",
    inputs = ["mpc-src-1.3.1", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["mpc-1.3.1"],
  },
  "mpc-src-1.3.1" = {
    type = "fetch",
    outputs = ["mpc-src-1.3.1"],
    url = [
      "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz",
      "https://mirrors.kernel.org/gnu/mpc/mpc-1.3.1.tar.gz",
    ],
    hash = "md5:5c9bc658c9fd0f940e8e3e0f09530c62",
  },
}
