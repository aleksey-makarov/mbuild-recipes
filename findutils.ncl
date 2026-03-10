{
  "buildscript-findutils-pass1-4.10.0" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-findutils-pass1-4.10.0"],
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
                  --localstatedir=/var/lib/locate  \
                  --host=x86_64-lfs-linux-gnu      \
                  --build="$(build-aux/config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      "%,
  },

  "findutils-pass1-4.10.0" = {
    type = "binary",
    inputs = [
      "findutils-src-4.10.0",
      "buildscript-findutils-pass1-4.10.0",
      "bootstrap-pass1",
    ],
    outputs = ["findutils-pass1-4.10.0"],
  },

  "findutils-src-4.10.0" = {
    type = "fetch",
    outputs = ["findutils-src-4.10.0"],
    url = [
      "https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz",
      "https://mirrors.kernel.org/gnu/findutils/findutils-4.10.0.tar.xz",
    ],
    hash = "md5:870cfd71c07d37ebe56f9f4aaf4ad872",
  },
}
