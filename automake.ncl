{
  "automake-1.18.1" = {
    type = "binary",
    status = "source fetch failed: ftp.gnu.org timed out; needs recipe mirror URLs",
    inputs = ["automake-src-1.18.1", "buildscript-autotools"],
    outputs = ["automake-1.18.1"],
  },

  "automake-src-1.18.1" = {
    type = "fetch",
    outputs = ["automake-src-1.18.1"],
    url = "https://ftp.gnu.org/gnu/automake/automake-1.18.1.tar.xz",
    hash = "md5:cea31dbf1120f890cbf2a3032cfb9a68",
  },
}
