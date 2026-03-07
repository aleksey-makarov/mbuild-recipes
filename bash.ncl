{
  "bash-src-5.3" = {
    type = "fetch",
    outputs = ["bash-src-5.3"],
    url = [
      "https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz",
      "https://mirrors.kernel.org/gnu/bash/bash-5.3.tar.gz",
    ],
    hash = "md5:977c8c0c5ae6309191e7768e28ebc951",
  },

  "bash-5.3" = {
    type = "binary",
    inputs = ["bash-src-5.3", "buildscript-autotools"],
    outputs = ["bash-5.3"],
  },

  "buildscript-bash-static-5.3" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-bash-static-5.3"],
    source =
      m%"
      #!/usr/bin/env bash
      set -euo pipefail
      src="/in/bash-src-5.3"
      out="/out/bash-static-5.3"
      cd "$src"
      rm -f config.cache
      CFLAGS="-O2 -static" LDFLAGS="-static" \
        ./configure --prefix="$out"
      make -j"$(nproc)"
      make install
      "%,
  },

  "bash-static-5.3" = {
    type = "binary",
    inputs = ["bash-src-5.3", "buildscript-bash-static-5.3"],
    outputs = ["bash-static-5.3"],
  },

}
