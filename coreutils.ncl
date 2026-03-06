{
  "coreutils-9.7" = {
    type = "binary",
    inputs = ["coreutils-src-9.7", "buildscript-autotools"],
    outputs = ["coreutils-9.7"],
  },

  "coreutils-static-9.7" = {
    type = "binary",
    inputs = ["coreutils-src-9.7"],
    outputs = ["coreutils-static-9.7"],
    script =
      m%"
      #!/usr/bin/env bash
      set -euo pipefail
      src="/in/coreutils-src-9.7"
      out="/out/coreutils-static-9.7"
      cd "$src"
      if [ -f Makefile ]; then
        make distclean || true
      fi
      rm -f config.cache
      CFLAGS="-O2 -static" LDFLAGS="-static" \
        ./configure --prefix="$out" --without-selinux
      make -j"$(nproc)"
      make install
      "%,
  },

  "coreutils-src-9.7" = {
    type = "fetch",
    outputs = ["coreutils-src-9.7"],
    url = [
      "https://ftp.gnu.org/gnu/coreutils/coreutils-9.7.tar.xz",
      "https://mirrors.kernel.org/gnu/coreutils/coreutils-9.7.tar.xz",
    ],
    hash = "md5:6b7285faf7d5eb91592bdd689270d3f1",
  },
}
