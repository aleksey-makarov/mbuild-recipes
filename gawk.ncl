{
  "buildscript-gawk-pass1-5.3.2" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-gawk-pass1-5.3.2"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      cd "/in/${src}"

      if [ ! -x ./configure ]; then
        candidates=()
        for d in ./*; do
          if [ -d "$d" ] && [ -x "$d/configure" ] && [ -x "$d/build-aux/config.guess" ]; then
            candidates+=("$d")
          fi
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          cd "${candidates[0]}"
        fi
      fi

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      sed -i 's/extras//' Makefile.in

      ./configure --prefix=/usr                    \
                  --host=x86_64-lfs-linux-gnu      \
                  --build="$(build-aux/config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "gawk-pass1-5.3.2" = {
    type = "binary",
    inputs = [
      "gawk-src-5.3.2",
      "buildscript-gawk-pass1-5.3.2",
      "bootstrap-pass1",
    ],
    outputs = ["gawk-pass1-5.3.2"],
  },

  "gawk-pass1-bootstrap-5.3.2" = {
    type = "binary",
    inputs = ["gawk-src-5.3.2", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["gawk-pass1-bootstrap-5.3.2"],
  },

  "gawk-src-5.3.2" = {
    type = "fetch",
    outputs = ["gawk-src-5.3.2"],
    url = [
      "https://ftp.gnu.org/gnu/gawk/gawk-5.3.2.tar.xz",
      "https://mirrors.kernel.org/gnu/gawk/gawk-5.3.2.tar.xz",
    ],
    hash = "md5:b7014650c5f45e5d4837c31209dc0037",
  },
}
