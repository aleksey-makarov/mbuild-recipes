{
  "buildscript-iana-etc-20250807" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-iana-etc-20250807"],
    source = m%"
      #!/bin/sh
      echo \"TODO: migrate this recipe to buildscript-*\" >&2
      exit 1
    "%,
  },

  "iana-etc-20250807" = {
    type = "binary",
    status = "missing dependency: dedicated buildscript artifact for iana-etc packaging",
    inputs = ["iana-etc-src-20250807", "buildscript-iana-etc-20250807", "bootstrap-binary-image"],
    outputs = ["iana-etc-20250807"],
  },

  "iana-etc-src-20250807" = {
    type = "github",
    outputs = ["iana-etc-src-20250807"],
    owner = "Mic92",
    repo = "iana-etc",
    rev = "cd4b443619943fc5e72d226fbc3c8cde7cfa52dd",
  },
}
