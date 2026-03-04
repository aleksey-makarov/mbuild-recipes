{
  "readline-8.3" = {
    type = "binary",
    inputs = ["readline-src-8.3", "buildscript-autotools"],
    outputs = ["readline-8.3"],
  },
  "readline-src-8.3" = {
    type = "fetch",
    outputs = ["readline-src-8.3"],
    url = [
      "https://ftp.gnu.org/gnu/readline/readline-8.3.tar.gz",
      "https://mirrors.kernel.org/gnu/readline/readline-8.3.tar.gz",
    ],
    hash = "md5:25a73bfb2a3ad7146c5e9d4408d9f6cd",
  },
}
