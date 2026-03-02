{
  "autoconf-2.72" = {
    type = "binary",
    status = "source fetch failed: ftp.gnu.org timed out; needs recipe mirror URLs",
    inputs = ["autoconf-src-2.72", "buildscript-autotools"],
    outputs = ["autoconf-2.72"],
  },

  "autoconf-src-2.72" = {
    type = "fetch",
    outputs = ["autoconf-src-2.72"],
    url = "https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz",
    hash = "md5:1be79f7106ab6767f18391c5e22be701",
  },
}
