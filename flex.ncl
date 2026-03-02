{
  "flex-2.6.4" = {
    type = "binary",
    status = "provide `autopoint` (gettext tooling) in the builder image",
    inputs = ["flex-src-2.6.4", "buildscript-autotools"],
    outputs = ["flex-2.6.4"],
  },

  "flex-src-2.6.4" = {
    type = "github",
    outputs = ["flex-src-2.6.4"],
    owner = "westes",
    repo = "flex",
    rev = "ab49343b08c933e32de8de78132649f9560a3727",
  },
}
