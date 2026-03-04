{
  "buildscript-autotools" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-autotools"],
    source = import "autotools.sh" as 'Text,
  },

  "buildscript-cmake" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-cmake"],
    source = import "cmake.sh" as 'Text,
  },

  "buildscript-gnu-make" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-gnu-make"],
    source = import "gnu-make.sh" as 'Text,
  },

  "buildscript-meson" = {
    type = "text",
    artifact_kind = "build-script",
    outputs = ["buildscript-meson"],
    source = import "meson.sh" as 'Text,
  },
}
