{
  "buildscript-xz-pass1-5.8.1" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-xz-pass1-5.8.1"],
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
                  --host=x86_64-lfs-linux-gnu       \
                  --build="$(build-aux/config.guess)" \
                  --disable-static                  \
                  --docdir=/usr/share/doc/xz-5.8.1

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install
      rm -fv "/out/${out}/bootstrap-root/usr/lib/liblzma.la"
      "%,
  },

  "xz-pass1-5.8.1" = {
    type = "binary",
    inputs = [
      "xz-src-5.8.1",
      "buildscript-xz-pass1-5.8.1",
      "bootstrap-pass1",
    ],
    outputs = ["xz-pass1-5.8.1"],
  },

  "xz-src-5.8.1" = {
    type = "fetch",
    outputs = ["xz-src-5.8.1"],
    url = "https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.xz",
    hash = "md5:cf5e1feb023d22c6bdaa30e84ef3abe3",
  },
}
