{
  "buildscript-patch-pass1-2.8" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-patch-pass1-2.8"],
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

  "patch-pass1-2.8" = {
    type = "binary",
    inputs = [
      "patch-src-2.8",
      "buildscript-patch-pass1-2.8",
      "bootstrap-pass1",
    ],
    outputs = ["patch-pass1-2.8"],
  },
  "patch-src-2.8" = {
    type = "fetch",
    outputs = ["patch-src-2.8"],
    url = [
      "https://ftp.gnu.org/gnu/patch/patch-2.8.tar.xz",
      "https://mirrors.kernel.org/gnu/patch/patch-2.8.tar.xz",
    ],
    hash = "md5:149327a021d41c8f88d034eab41c039f",
  },
}
