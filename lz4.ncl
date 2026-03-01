{
  "lz4-1.10.0" = {
    type = "binary",
    inputs = ["lz4-src-1.10.0", "buildscript-gnu-make"],
    outputs = ["lz4-1.10.0"],
  },

  "lz4-src-1.10.0" = {
    type = "github",
    outputs = ["lz4-src-1.10.0"],
    owner = "lz4",
    repo = "lz4",
    rev = "ebb370ca83af193212df4dcbadcc5d87bc0de2f0",
  },
}
