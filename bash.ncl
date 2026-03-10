{
  "buildscript-bash-pass1-5.3" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-bash-pass1-5.3"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      cd "/in/${src}"

      if [ ! -x ./configure ]; then
        candidates=()
        for d in ./*; do
          if [ -d "$d" ] && [ -x "$d/configure" ] && [ -x "$d/support/config.guess" ]; then
            candidates+=("$d")
          fi
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          cd "${candidates[0]}"
        fi
      fi

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      ./configure --prefix=/usr                      \
                  --build="$(sh support/config.guess)" \
                  --host=x86_64-lfs-linux-gnu       \
                  --without-bash-malloc

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      mkdir -p "/out/${out}/bootstrap-root/bin"
      ln -svf ../usr/bin/bash "/out/${out}/bootstrap-root/bin/sh"
      "%,
  },

  "bash-src-5.3" = {
    type = "fetch",
    outputs = ["bash-src-5.3"],
    url = [
      "https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz",
      "https://mirrors.kernel.org/gnu/bash/bash-5.3.tar.gz",
    ],
    hash = "md5:977c8c0c5ae6309191e7768e28ebc951",
  },

  "bash-pass1-5.3" = {
    type = "binary",
    inputs = ["bash-src-5.3", "buildscript-bash-pass1-5.3", "bootstrap-pass1"],
    outputs = ["bash-pass1-5.3"],
  },

  "buildscript-bash-static-5.3" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-bash-static-5.3"],
    source = m%"
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
    inputs = ["bash-src-5.3", "buildscript-bash-static-5.3", "bootstrap-binary-image"],
    outputs = ["bash-static-5.3"],
  },
}
