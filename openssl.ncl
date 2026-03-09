{
  "buildscript-openssl-3.5.2" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-openssl-3.5.2"],
    source = m%"
      #!/bin/sh
      echo \"TODO: migrate this recipe to buildscript-*\" >&2
      exit 1
    "%,
  },

  "openssl-3.5.2" = {
    type = "binary",
    status = "missing dependency: dedicated OpenSSL buildscript artifact",
    inputs = ["openssl-src-3.5.2", "buildscript-openssl-3.5.2", "bootstrap-binary-image"],
    outputs = ["openssl-3.5.2"],
  },

  "openssl-src-3.5.2" = {
    type = "github",
    outputs = ["openssl-src-3.5.2"],
    owner = "openssl",
    repo = "openssl",
    rev = "0893a62353583343eb712adef6debdfbe597c227",
  },
}
