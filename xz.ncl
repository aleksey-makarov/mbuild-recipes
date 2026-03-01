{
  "xz-5.8.1" = {
    type = "binary",
    inputs = ["xz-src-5.8.1", "buildscript-cmake"],
    outputs = ["xz-5.8.1"],
  },

  "xz-src-5.8.1" = {
    type = "github",
    outputs = ["xz-src-5.8.1"],
    owner = "tukaani-project",
    repo = "xz",
    rev = "a522a226545730551f7e7c2685fab27cf567746c",
  },
}
