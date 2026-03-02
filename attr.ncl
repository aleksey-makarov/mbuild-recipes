{
  "attr-2.5.2" = {
    type = "binary",
    inputs = ["attr-src-2.5.2", "buildscript-autotools"],
    outputs = ["attr-2.5.2"],
  },

  "attr-src-2.5.2" = {
    type = "fetch",
    outputs = ["attr-src-2.5.2"],
    url = "https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz",
    hash = "md5:227043ec2f6ca03c0948df5517f9c927",
  },
}
