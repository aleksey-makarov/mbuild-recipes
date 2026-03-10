# Bootstrap Layout Conventions

This document defines path and install conventions for temporary (pass1) toolchain artifacts.

## Target Root Model

- Target root (sysroot): `/bootstrap-root`
- Temporary toolchain prefix: `/bootstrap-root/tools`
- Inside recipe outputs, files are staged under `DESTDIR` and then published as objects.

This mirrors the LFS split between target root and temporary tools, while keeping the build container root (`/`) separate.

## Path Rules

- Pass1 toolchain binaries must be installed under:
  - `/bootstrap-root/tools/bin`
- Target headers and libraries must be installed under:
  - `/bootstrap-root/usr/include`
  - `/bootstrap-root/usr/lib`
- Build scripts must not install pass1 payload directly into `/usr` or `/tools` in the container root.

## Configure / Install Rules

For pass1 recipes:

- Use `--with-sysroot=/bootstrap-root` where applicable (binutils/gcc pass1).
- Use `--prefix=/bootstrap-root/tools` for temporary toolchain components.
- Use `DESTDIR="/out/${out}/bootstrap-root"` when installing target-side outputs.
- If a recipe requires explicit dependency roots (for example GMP/MPFR/MPC), point them to `/bootstrap-root/usr`.

## Binary Builder Image Expectations

Binary recipes that participate in pass1 should run on an image where:

- `/bootstrap-root` contains all required previously built pass1 artifacts;
- `PATH` is adjusted by build scripts when needed (for example `/bootstrap-root/tools/bin` first).

## Common Pitfalls

- Double prefix nesting (`/bootstrap-root/bootstrap-root/...`) caused by combining absolute install paths with `DESTDIR` incorrectly.
- Accidental host/distro header leakage from `/usr/include` when sysroot/path flags are missing.
- Mixing host deps and pass1 deps without explicit `--with-*` paths.

## Practical Check

Before moving to the next stage, verify:

- toolchain binaries exist in `/bootstrap-root/tools/bin`;
- target headers/libs exist under `/bootstrap-root/usr/...`;
- no published output contains duplicated bootstrap-root prefixes.
