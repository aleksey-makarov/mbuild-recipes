{
  "bash-static-image-5.3" = {
    type = "image",
    inputs = ["bash-static-5.3"],
    outputs = ["bash-static-image-5.3"],
  },

  "bash-coreutils-static-image-5.3-9.7" = {
    type = "image",
    inputs = ["bash-static-5.3", "coreutils-static-9.7"],
    outputs = ["bash-coreutils-static-image-5.3-9.7"],
  },
}
