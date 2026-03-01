{
  "sysvinit-3.14" = {
    type = "binary",
    inputs = ["sysvinit-src-3.14", "buildscript-gnu-make"],
    outputs = ["sysvinit-3.14"],
  },

  "sysvinit-src-3.14" = {
    type = "github",
    outputs = ["sysvinit-src-3.14"],
    owner = "slicer69",
    repo = "sysvinit",
    rev = "6122147daea8420c12d8d6f929cfb2cd51105d68",
  },
}
