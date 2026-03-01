{
  "libffi-3.5.2" = {
    type = "binary",
    inputs = ["libffi-src-3.5.2", "buildscript-autotools"],
    outputs = ["libffi-3.5.2"],
  },

  "libffi-src-3.5.2" = {
    type = "github",
    outputs = ["libffi-src-3.5.2"],
    owner = "libffi",
    repo = "libffi",
    rev = "e2eda0cf72a0598b44278cc91860ea402273fa29",
  },
}
