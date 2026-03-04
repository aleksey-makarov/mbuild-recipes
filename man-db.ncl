{
  "man-db-2.13.1" = {
    type = "binary",
    status = "build failed: configure cannot find libpipeline via pkg-config (needs dependency wiring)",
    inputs = ["man-db-src-2.13.1", "buildscript-autotools"],
    outputs = ["man-db-2.13.1"],
  },
  "man-db-src-2.13.1" = {
    type = "fetch",
    outputs = ["man-db-src-2.13.1"],
    url = "https://download.savannah.gnu.org/releases/man-db/man-db-2.13.1.tar.xz",
    hash = "md5:b6335533cbeac3b24cd7be31fdee8c83",
  },
}
