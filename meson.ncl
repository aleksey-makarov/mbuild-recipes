{
  "meson-1.8.3" = {
    type = "binary",
    status = "add a dedicated build-script artifact for Meson project installation",
    inputs = ["meson-src-1.8.3"],
    outputs = ["meson-1.8.3"],
    script = m%"
      #!/bin/sh
      echo "TODO: migrate this recipe to buildscript-*" >&2
      exit 1
    "%,
  },

  "meson-src-1.8.3" = {
    type = "github",
    outputs = ["meson-src-1.8.3"],
    owner = "mesonbuild",
    repo = "meson",
    rev = "872ae45f7f088524676eccf26959f0fd6dfa1b13",
  },
}
