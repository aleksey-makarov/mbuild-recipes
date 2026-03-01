{
  "iana-etc-20250807" = {
    type = "binary",
    inputs = ["iana-etc-src-20250807"],
    outputs = ["iana-etc-20250807"],
    script = m%"
      #!/bin/sh
      echo "TODO: migrate this recipe to buildscript-*" >&2
      exit 1
    "%,
  },

  "iana-etc-src-20250807" = {
    type = "github",
    outputs = ["iana-etc-src-20250807"],
    owner = "Mic92",
    repo = "iana-etc",
    rev = "cd4b443619943fc5e72d226fbc3c8cde7cfa52dd",
  },
}
