{
  "tcl-documentation-8.6.16" = {
    type = "binary",
    status = "source fetch failed: sourceforge URL returns hash-mismatched payload (docs buildscript still not defined)",
    inputs = ["tcl-documentation-src-8.6.16", "bootstrap-binary-image"],
    outputs = ["tcl-documentation-8.6.16"],
  },
  "tcl-documentation-src-8.6.16" = {
    type = "fetch",
    outputs = ["tcl-documentation-src-8.6.16"],
    url = "https://downloads.sourceforge.net/tcl/tcl8.6.16-html.tar.gz",
    hash = "md5:750c221bcb6f8737a6791c1fbe98b684",
  },
}
