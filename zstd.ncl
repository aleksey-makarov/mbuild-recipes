{
  "zstd-1.5.7" = {
    type = "binary",
    inputs = ["zstd-src-1.5.7", "buildscript-gnu-make"],
    outputs = ["zstd-1.5.7"],
  },

  "zstd-src-1.5.7" = {
    type = "github",
    outputs = ["zstd-src-1.5.7"],
    owner = "facebook",
    repo = "zstd",
    rev = "f8745da6ff1ad1e7bab384bd1f9d742439278e99",
  },
}
