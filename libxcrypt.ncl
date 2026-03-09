{
  "libxcrypt-4.4.38" = {
    type = "binary",
    inputs = ["libxcrypt-src-4.4.38", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["libxcrypt-4.4.38"],
  },

  "libxcrypt-src-4.4.38" = {
    type = "github",
    outputs = ["libxcrypt-src-4.4.38"],
    owner = "besser82",
    repo = "libxcrypt",
    rev = "55ea777e8d567e5e86ffac917c28815ac54cc341",
  },
}
