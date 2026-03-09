{
  "sysklogd-2.7.2" = {
    type = "binary",
    inputs = ["sysklogd-src-2.7.2", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["sysklogd-2.7.2"],
  },

  "sysklogd-src-2.7.2" = {
    type = "github",
    outputs = ["sysklogd-src-2.7.2"],
    owner = "troglobit",
    repo = "sysklogd",
    rev = "5fb314cb9060afa3bd4eed2f0be3200f02f729e9",
  },
}
