{
  "buildscript-coreutils-pass1-9.7" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-coreutils-pass1-9.7"],
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

      ./configure --prefix=/usr                          \
                  --host=x86_64-lfs-linux-gnu           \
                  --build="$(build-aux/config.guess)"   \
                  --enable-install-program=hostname     \
                  --enable-no-install-program=kill,uptime

      jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
      make -j"${jobs}"
      make DESTDIR="/out/${out}/bootstrap-root" install

      mkdir -pv "/out/${out}/bootstrap-root/usr/sbin"
      mv -v "/out/${out}/bootstrap-root/usr/bin/chroot" \
            "/out/${out}/bootstrap-root/usr/sbin/chroot"
      mkdir -pv "/out/${out}/bootstrap-root/usr/share/man/man8"
      mv -v "/out/${out}/bootstrap-root/usr/share/man/man1/chroot.1" \
            "/out/${out}/bootstrap-root/usr/share/man/man8/chroot.8"
      sed -i 's/\"1\"/\"8\"/' \
             "/out/${out}/bootstrap-root/usr/share/man/man8/chroot.8"
      "%,
  },

  "coreutils-src-9.7" = {
    type = "fetch",
    outputs = ["coreutils-src-9.7"],
    url = [
      "https://ftp.gnu.org/gnu/coreutils/coreutils-9.7.tar.xz",
      "https://mirrors.kernel.org/gnu/coreutils/coreutils-9.7.tar.xz",
    ],
    hash = "md5:6b7285faf7d5eb91592bdd689270d3f1",
  },

  "coreutils-pass1-9.7" = {
    type = "binary",
    inputs = [
      "coreutils-src-9.7",
      "buildscript-coreutils-pass1-9.7",
      "bootstrap-pass1",
    ],
    outputs = ["coreutils-pass1-9.7"],
  },

  "buildscript-coreutils-static-9.7" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-coreutils-static-9.7"],
    source = m%"
      #!/usr/bin/env bash
      set -euo pipefail
      src="/in/coreutils-src-9.7"
      out="/out/coreutils-static-9.7"
      cd "$src"
      if [ -f Makefile ]; then
        make distclean || true
      fi
      rm -f config.cache
      CFLAGS="-O2 -static" LDFLAGS="-static" \
        ./configure --prefix="$out" --without-selinux
      make -j"$(nproc)"
      make install
      "%,
  },

  "coreutils-static-9.7" = {
    type = "binary",
    inputs = ["coreutils-src-9.7", "buildscript-coreutils-static-9.7", "bootstrap-binary-image"],
    outputs = ["coreutils-static-9.7"],
  },
}
