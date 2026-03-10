let autotools = import "autotools.ncl" in
{
  "buildscript-autotools" =
    autotools.autotools {
      output = "buildscript-autotools",
    },

  "buildscript-autotools-bootstrap-root" =
    autotools.autotools {
      output = "buildscript-autotools-bootstrap-root",
      install = "make DESTDIR=\"/out/${out}/bootstrap-root\"",
      install_args = ["install"],
    },

  "buildscript-autotools-pass1" =
    autotools.autotools {
      output = "buildscript-autotools-pass1",
      install = "make DESTDIR=\"/out/${out}/bootstrap-root\"",
      install_args = ["install"],
      prepend_path = ["/bootstrap-root/tools/bin"],
      configure_args = [
        "--host=x86_64-lfs-linux-gnu",
        "--build=x86_64-pc-linux-gnu",
      ],
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
