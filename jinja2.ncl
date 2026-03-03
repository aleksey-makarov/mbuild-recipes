{
  "jinja2-3.1.6" = {
    type = "binary",
    status = "no build-script input (python package build flow/buildscript not implemented yet)",
    inputs = ["jinja2-src-3.1.6"],
    outputs = ["jinja2-3.1.6"],
  },

  "jinja2-src-3.1.6" = {
    type = "fetch",
    outputs = ["jinja2-src-3.1.6"],
    url = "https://pypi.org/packages/source/J/Jinja2/jinja2-3.1.6.tar.gz",
    hash = "md5:66d4c25ff43d1deaf9637ccda523dec8",
  },
}
