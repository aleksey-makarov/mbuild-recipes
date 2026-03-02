{
  "expect-5.45.4" = {
    type = "binary",
    status = "source fetch hash mismatch from SourceForge mirror response; needs stable mirror URL",
    inputs = ["expect-src-5.45.4", "buildscript-autotools"],
    outputs = ["expect-5.45.4"],
  },

  "expect-src-5.45.4" = {
    type = "fetch",
    outputs = ["expect-src-5.45.4"],
    url = "https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz",
    hash = "md5:00fce8de158422f5ccd2666512329bd2",
  },
}
