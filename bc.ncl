{
  "bc-7.0.3" = {
    type = "binary",
    inputs = ["bc-src-7.0.3", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["bc-7.0.3"],
  },

  "bc-src-7.0.3" = {
    type = "github",
    outputs = ["bc-src-7.0.3"],
    owner = "gavinhoward",
    repo = "bc",
    rev = "c8dabac65d39fd527a9264a5e505a99b1d8df3d8",
  },
}
