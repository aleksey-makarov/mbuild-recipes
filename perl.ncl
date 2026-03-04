{
  "perl-5.42.0" = {
    type = "binary",
    status = "no generic perl buildscript yet (Configure/make/install flow)",
    inputs = ["perl-src-5.42.0"],
    outputs = ["perl-5.42.0"],
  },
  "perl-src-5.42.0" = {
    type = "fetch",
    outputs = ["perl-src-5.42.0"],
    url = "https://www.cpan.org/src/5.0/perl-5.42.0.tar.xz",
    hash = "md5:7a6950a9f12d01eb96a9d2ed2f4e0072",
  },
}
