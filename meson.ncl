{
  "buildscript-meson-1.8.3" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-meson-1.8.3"],
    source = m%"
      #!/bin/sh
      echo \"TODO: migrate this recipe to buildscript-*\" >&2
      exit 1
    "%,
  },

  "meson-1.8.3" = {
    type = "binary",
    status = "missing dependency: dedicated Meson buildscript artifact",
    inputs = ["meson-src-1.8.3", "buildscript-meson-1.8.3", "bootstrap-binary-image"],
    outputs = ["meson-1.8.3"],
  },

  "meson-src-1.8.3" = {
    type = "github",
    outputs = ["meson-src-1.8.3"],
    owner = "mesonbuild",
    repo = "meson",
    rev = "872ae45f7f088524676eccf26959f0fd6dfa1b13",
  },
}
