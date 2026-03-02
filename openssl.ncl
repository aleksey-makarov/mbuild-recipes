{
  "openssl-3.5.2" = {
    type = "binary",
    status = "missing dependency: dedicated OpenSSL buildscript artifact",
    inputs = ["openssl-src-3.5.2"],
    outputs = ["openssl-3.5.2"],
    script = m%"
      #!/bin/sh
      echo "TODO: migrate this recipe to buildscript-*" >&2
      exit 1
    "%,
  },

  "openssl-src-3.5.2" = {
    type = "github",
    outputs = ["openssl-src-3.5.2"],
    owner = "openssl",
    repo = "openssl",
    rev = "0893a62353583343eb712adef6debdfbe597c227",
  },
}
