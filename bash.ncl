{
  "bash-5.3" = {
    type = "binary",
    inputs = ["bash-src-5.3", "buildscript-autotools"],
    outputs = ["bash-5.3"],
  },

  "bash-src-5.3" = {
    type = "fetch",
    outputs = ["bash-src-5.3"],
    url = [
      "https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz",
      "https://mirrors.kernel.org/gnu/bash/bash-5.3.tar.gz",
    ],
    hash = "md5:977c8c0c5ae6309191e7768e28ebc951",
  },
}
