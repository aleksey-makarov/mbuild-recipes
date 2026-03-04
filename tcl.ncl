{
  "tcl-8.6.16" = {
    type = "binary",
    status = "source fetch failed: sourceforge URL returns hash-mismatched payload (and no generic tcl buildscript yet)",
    inputs = ["tcl-src-8.6.16"],
    outputs = ["tcl-8.6.16"],
  },
  "tcl-src-8.6.16" = {
    type = "fetch",
    outputs = ["tcl-src-8.6.16"],
    url = "https://downloads.sourceforge.net/tcl/tcl8.6.16-src.tar.gz",
    hash = "md5:eaef5d0a27239fb840f04af8ec608242",
  },
}
