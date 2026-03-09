{
  "acl-2.3.2" = {
    type = "binary",
    status = "missing dependency artifact: attr development headers (attr/error_context.h)",
    inputs = ["acl-src-2.3.2", "buildscript-autotools", "bootstrap-binary-image"],
    outputs = ["acl-2.3.2"],
  },

  "acl-src-2.3.2" = {
    type = "fetch",
    outputs = ["acl-src-2.3.2"],
    url = "https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz",
    hash = "md5:590765dee95907dbc3c856f7255bd669",
  },
}
