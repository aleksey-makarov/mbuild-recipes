{
  "xml-parser-2.47" = {
    type = "binary",
    status = "no generic perl-module buildscript yet",
    inputs = ["xml-parser-src-2.47", "bootstrap-binary-image"],
    outputs = ["xml-parser-2.47"],
  },
  "xml-parser-src-2.47" = {
    type = "fetch",
    outputs = ["xml-parser-src-2.47"],
    url = "https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz",
    hash = "md5:89a8e82cfd2ad948b349c0a69c494463",
  },
}
