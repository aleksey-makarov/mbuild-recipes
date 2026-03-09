{
  "vim-9.1.1629" = {
    type = "binary",
    inputs = ["vim-src-9.1.1629", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["vim-9.1.1629"],
  },

  "vim-src-9.1.1629" = {
    type = "github",
    outputs = ["vim-src-9.1.1629"],
    owner = "vim",
    repo = "vim",
    rev = "706b6f5867cb0fe65c4fefac8382fe2995eedde7",
  },
}
