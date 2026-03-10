{
  "buildscript-sed-pass1-4.9" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-sed-pass1-4.9"],
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

      ./configure --prefix=/usr                    \
                  --host=x86_64-lfs-linux-gnu      \
                  --build="$(./build-aux/config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "sed-pass1-4.9" = {
    type = "binary",
    inputs = [
      "sed-src-4.9",
      "buildscript-sed-pass1-4.9",
      "bootstrap-pass1",
    ],
    outputs = ["sed-pass1-4.9"],
  },
  "sed-src-4.9" = {
    type = "fetch",
    outputs = ["sed-src-4.9"],
    url = [
      "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz",
      "https://mirrors.kernel.org/gnu/sed/sed-4.9.tar.xz",
    ],
    hash = "md5:6aac9b2dbafcd5b7a67a8a9bcb8036c3",
  },
}
