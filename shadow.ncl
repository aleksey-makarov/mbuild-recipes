{
  "shadow-4.18.0" = {
    type = "binary",
    status = "missing build dependencies: autopoint, xsltproc",
    inputs = ["shadow-src-4.18.0", "buildscript-autotools"],
    outputs = ["shadow-4.18.0"],
  },

  "shadow-src-4.18.0" = {
    type = "github",
    outputs = ["shadow-src-4.18.0"],
    owner = "shadow-maint",
    repo = "shadow",
    rev = "045652a925a4c8016dfae8d42c03f8c23df2103e",
  },
}
