{
  "ninja-1.13.1" = {
    type = "binary",
    inputs = ["ninja-src-1.13.1", "buildscript-cmake"],
    outputs = ["ninja-1.13.1"],
  },

  "ninja-src-1.13.1" = {
    type = "github",
    outputs = ["ninja-src-1.13.1"],
    owner = "ninja-build",
    repo = "ninja",
    rev = "79feac0f3e3bc9da9effc586cd5fea41e7550051",
  },
}
