{
  "expat-2.7.1" = {
    type = "binary",
    inputs = ["expat-src-2.7.1", "buildscript-cmake"],
    outputs = ["expat-2.7.1"],
  },

  "expat-src-2.7.1" = {
    type = "github",
    outputs = ["expat-src-2.7.1"],
    owner = "libexpat",
    repo = "libexpat",
    rev = "f9a3eeb3e09fbea04b1c451ffc422ab2f1e45744",
  },
}
