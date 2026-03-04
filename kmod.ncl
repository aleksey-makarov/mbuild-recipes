{
  "kmod-34.2" = {
    type = "binary",
    status = "build failed: meson requires scdoc program (man/meson.build)",
    inputs = ["kmod-src-34.2", "buildscript-meson"],
    outputs = ["kmod-34.2"],
  },
  "kmod-src-34.2" = {
    type = "fetch",
    outputs = ["kmod-src-34.2"],
    url = "https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-34.2.tar.xz",
    hash = "md5:36f2cc483745e81ede3406fa55e1065a",
  },
}
