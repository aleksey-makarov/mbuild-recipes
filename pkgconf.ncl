{
  "pkgconf-2.5.1" = {
    type = "binary",
    inputs = ["pkgconf-src-2.5.1", "buildscript-meson", "bootstrap-binary-image"],
    outputs = ["pkgconf-2.5.1"],
  },
  "pkgconf-src-2.5.1" = {
    type = "fetch",
    outputs = ["pkgconf-src-2.5.1"],
    url = "https://distfiles.ariadne.space/pkgconf/pkgconf-2.5.1.tar.xz",
    hash = "md5:3291128c917fdb8fccd8c9e7784b643b",
  },
}
