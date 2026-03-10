{
  "buildscript-diffutils-pass1-3.12" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-diffutils-pass1-3.12"],
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

      ./configure --prefix=/usr                     \
                  --host=x86_64-lfs-linux-gnu      \
                  gl_cv_func_strcasecmp_works=y    \
                  --build="$(./build-aux/config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "diffutils-pass1-3.12" = {
    type = "binary",
    inputs = [
      "diffutils-src-3.12",
      "buildscript-diffutils-pass1-3.12",
      "bootstrap-pass1",
    ],
    outputs = ["diffutils-pass1-3.12"],
  },

  "diffutils-src-3.12" = {
    type = "fetch",
    outputs = ["diffutils-src-3.12"],
    url = [
      "https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz",
      "https://mirrors.kernel.org/gnu/diffutils/diffutils-3.12.tar.xz",
    ],
    hash = "md5:d1b18b20868fb561f77861cd90b05de4",
  },
}
