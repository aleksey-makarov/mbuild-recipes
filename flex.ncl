{
  "flex-2.6.4" = {
    type = "binary",
    status = "missing build dependencies: autopoint, help2man",
    inputs = ["flex-src-2.6.4", "buildscript-autotools", "bootstrap-binary-image"],
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
