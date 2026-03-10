{
  "buildscript-tar-pass1-1.35" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-tar-pass1-1.35"],
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

  "tar-pass1-1.35" = {
    type = "binary",
    inputs = [
      "tar-src-1.35",
      "buildscript-tar-pass1-1.35",
      "bootstrap-pass1",
    ],
    outputs = ["tar-pass1-1.35"],
  },
  "tar-src-1.35" = {
    type = "fetch",
    outputs = ["tar-src-1.35"],
    url = [
      "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz",
      "https://mirrors.kernel.org/gnu/tar/tar-1.35.tar.xz",
    ],
    hash = "md5:a2d8042658cfd8ea939e6d911eaf4152",
  },
}
