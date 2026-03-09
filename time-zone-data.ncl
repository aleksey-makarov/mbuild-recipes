{
  "time-zone-data-2025b" = {
    type = "binary",
    status = "data package; no generic data/install buildscript yet",
    inputs = ["time-zone-data-src-2025b", "bootstrap-binary-image"],
    outputs = ["time-zone-data-2025b"],
  },
  "time-zone-data-src-2025b" = {
    type = "fetch",
    outputs = ["time-zone-data-src-2025b"],
    url = "https://www.iana.org/time-zones/repository/releases/tzdata2025b.tar.gz",
    hash = "md5:ad65154c48c74a9b311fe84778c5434f",
  },
}
