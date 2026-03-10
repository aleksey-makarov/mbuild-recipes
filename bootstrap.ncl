{
  "bootstrap-binary-image" = {
    type = "container-image",
    image = "docker.io/library/buildpack-deps:bookworm",
    digest = "sha256:b8d12fbc4f3afb47b1e8d765e688bc16c0a79310ec23a6673e28c036eed810b8",
    outputs = ["bootstrap-binary-image"],
  },

  "bootstrap-for-mpc-pass1-1.3.1" = {
    type = "image",
    inputs = ["bootstrap-binary-image", "mpfr-pass1-4.2.2"],
    outputs = ["bootstrap-for-mpc-pass1-1.3.1"],
  },

  "bootstrap-for-gcc-pass1-15.2.0" = {
    type = "image",
    inputs = [
      "bootstrap-for-mpc-pass1-1.3.1",
      "binutils-pass1-2.45",
      "gmp-pass1-6.3.0",
      "mpc-pass1-1.3.1",
    ],
    outputs = ["bootstrap-for-gcc-pass1-15.2.0"],
  },

  "bootstrap-for-glibc-pass1-2.42" = {
    type = "image",
    inputs = [
      "bootstrap-for-gcc-pass1-15.2.0",
      "gcc-pass1-15.2.0",
      "linux-api-headers-6.18.10",
      "bison-3.8.2",
      "gawk-5.3.2",
    ],
    outputs = ["bootstrap-for-glibc-pass1-2.42"],
  },

  "bootstrap-for-libstdcxx-pass1-15.2.0" = {
    type = "image",
    inputs = ["bootstrap-for-glibc-pass1-2.42", "glibc-pass1-2.42"],
    outputs = ["bootstrap-for-libstdcxx-pass1-15.2.0"],
  },

  "bootstrap-pass1" = {
    type = "image",
    inputs = [
      "bootstrap-for-libstdcxx-pass1-15.2.0",
      "libstdcxx-pass1-15.2.0",
    ],
    outputs = ["bootstrap-pass1"],
  },
}
