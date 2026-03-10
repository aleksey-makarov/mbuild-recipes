{
  "buildscript-file-pass1-5.46" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-file-pass1-5.46"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail

      src="${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}"
      out="${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}"

      cd "/in/${src}"

      if [ ! -x ./configure ]; then
        candidates=()
        for d in ./*; do
          if [ -d "$d" ] && [ -x "$d/configure" ] && [ -x "$d/config.guess" ]; then
            candidates+=("$d")
          fi
        done
        if [ "${#candidates[@]}" -eq 1 ]; then
          cd "${candidates[0]}"
        fi
      fi

      export PATH="/bootstrap-root/tools/bin:${PATH:-}"

      mkdir -p build
      pushd build
        ../configure --disable-bzlib      \
                     --disable-libseccomp \
                     --disable-xzlib      \
                     --disable-zlib
        jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
        make -j"${jobs}"
      popd

      ./configure --prefix=/usr                \
                  --host=x86_64-lfs-linux-gnu  \
                  --build="$(./config.guess)"

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}" FILE_COMPILE="$(pwd)/build/src/file"
      make DESTDIR="/out/${out}/bootstrap-root" install
      rm -fv "/out/${out}/bootstrap-root/usr/lib/libmagic.la"
      "%,
  },

  "file-pass1-5.46" = {
    type = "binary",
    inputs = [
      "file-src-5.46",
      "buildscript-file-pass1-5.46",
      "bootstrap-pass1",
    ],
    outputs = ["file-pass1-5.46"],
  },

  "file-src-5.46" = {
    type = "fetch",
    outputs = ["file-src-5.46"],
    url = "https://astron.com/pub/file/file-5.46.tar.gz",
    hash = "md5:459da2d4b534801e2e2861611d823864",
  },
}
