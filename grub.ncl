{
  "grub-2.12" = {
    type = "binary",
    status = "build failed: missing grub-core/extra_deps.lst in make; needs grub-specific build flow",
    inputs = ["grub-src-2.12", "buildscript-autotools"],
    outputs = ["grub-2.12"],
  },
  "grub-src-2.12" = {
    type = "fetch",
    outputs = ["grub-src-2.12"],
    url = [
      "https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz",
      "https://mirrors.kernel.org/gnu/grub/grub-2.12.tar.xz",
    ],
    hash = "md5:60c564b1bdc39d8e43b3aab4bc0fb140",
  },
}
