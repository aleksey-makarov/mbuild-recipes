{
  "coreutils-9.7" = {
    type = "binary",
    inputs = ["coreutils-src-9.7", "buildscript-autotools"],
    outputs = ["coreutils-9.7"],
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
}
