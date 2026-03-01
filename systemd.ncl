{
  "systemd-257.8" = {
    type = "binary",
    inputs = ["systemd-src-257.8", "buildscript-meson"],
    outputs = ["systemd-257.8"],
  },

  "systemd-src-257.8" = {
    type = "github",
    outputs = ["systemd-src-257.8"],
    owner = "systemd",
    repo = "systemd",
    rev = "5e38d199a623563698ab4a69acbbe3afa9135198",
  },
}
