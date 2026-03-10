{
  "buildscript-make-pass1-4.4.1" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-make-pass1-4.4.1"],
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
                  --build="$(build-aux/config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "make-pass1-4.4.1" = {
    type = "binary",
    inputs = [
      "make-src-4.4.1",
      "buildscript-make-pass1-4.4.1",
      "bootstrap-pass1",
    ],
    outputs = ["make-pass1-4.4.1"],
  },
  "make-src-4.4.1" = {
    type = "fetch",
    outputs = ["make-src-4.4.1"],
    url = [
      "https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz",
      "https://mirrors.kernel.org/gnu/make/make-4.4.1.tar.gz",
    ],
    hash = "md5:c8469a3713cbbe04d955d4ae4be23eeb",
  },
}
