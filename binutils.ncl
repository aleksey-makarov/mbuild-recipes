{
  "buildscript-binutils-pass1-2.45" =
    (import "build/autotools.ncl").autotools {
      output = "buildscript-binutils-pass1-2.45",
      in_source = false,
      configure_args = [
        "--prefix=/out/binutils-pass1-2.45/tools",
        "--with-sysroot=/out/binutils-pass1-2.45",
        "--target=x86_64-lfs-linux-gnu",
        "--disable-nls",
        "--enable-gprofng=no",
        "--disable-werror",
        "--enable-new-dtags",
        "--enable-default-hash-style=gnu",
      ],
    },

  "binutils-pass1-2.45" = {
    type = "binary",
    inputs = ["binutils-src-2.45", "buildscript-binutils-pass1-2.45", "bootstrap-binary-image"],
    outputs = ["binutils-pass1-2.45"],
  },

  "binutils-src-2.45" = {
    type = "fetch",
    outputs = ["binutils-src-2.45"],
    url = "https://sourceware.org/pub/binutils/releases/binutils-2.45.tar.xz",
    hash = "md5:dee5b4267e0305a99a3c9d6131f45759",
  },
}
