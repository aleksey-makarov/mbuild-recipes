let shell_quote = fun value =>
  "'" ++ std.string.replace "'" "'\"'\"'" value ++ "'"
in

let render_args = fun args =>
  std.string.join " " (std.array.map shell_quote args)
in

let append_args = fun command args =>
  if args == [] then command else command ++ " " ++ render_args args
in

let ArgsContract = {
  output | String,
  configure | String | optional,
  configure_args | Array String | optional,
  make | String | optional,
  make_args | Array String | optional,
  install | String | optional,
  install_args | Array String | optional,
  env | { _ | String } | optional,
  prepend_path | Array String | optional,
  prepend_pkg_config_path | Array String | optional,
  prepend_cflags | Array String | optional,
  prepend_cppflags | Array String | optional,
  prepend_ldflags | Array String | optional,
  in_source | Bool | optional,
  build_dir | String | optional,
  autoreconf | Bool | optional,
  autoreconf_args | Array String | optional,
  pre_configure | String | optional,
  post_install | String | optional,
  ..
}
in

{
  autotools = fun cfg =>
    let cfg = cfg | ArgsContract in
    let get_or = fun key =>
      fun fallback =>
        if std.record.has_field key cfg then
          std.record.get key cfg
        else
          fallback
    in
    let output = std.record.get "output" cfg in
    let configure = get_or "configure" "./configure" in
    let configure_args = get_or "configure_args" [] in
    let make = get_or "make" "make" in
    let make_args = get_or "make_args" [] in
    let install = get_or "install" "make" in
    let install_args = get_or "install_args" ["install"] in
    let env = get_or "env" {} in
    let prepend_path = get_or "prepend_path" [] in
    let prepend_pkg_config_path = get_or "prepend_pkg_config_path" [] in
    let prepend_cflags = get_or "prepend_cflags" [] in
    let prepend_cppflags = get_or "prepend_cppflags" [] in
    let prepend_ldflags = get_or "prepend_ldflags" [] in
    let in_source = get_or "in_source" true in
    let build_dir = get_or "build_dir" "build" in
    let autoreconf = get_or "autoreconf" false in
    let autoreconf_args = get_or "autoreconf_args" ["-fi"] in
    let pre_configure = get_or "pre_configure" "" in
    let post_install = get_or "post_install" "" in
    let configure_cmd =
      let configure_program =
        if in_source then
          configure
        else if configure == "./configure" then
          "../configure"
        else
          configure
      in
      append_args (configure_program ++ " --prefix=\"/out/${out}\"") configure_args
    in
    let make_cmd = append_args make make_args ++ " -j\"$jobs\"" in
    let install_cmd = append_args install install_args in
    let env_lines =
      std.array.map
        (fun key => "export " ++ key ++ "=" ++ shell_quote (std.record.get key env))
        (std.record.fields env)
    in
    let prepend_lines = std.array.concat
      (std.array.concat
        (if prepend_path == [] then
          []
        else
          [
            "export PATH="
              ++ shell_quote (std.string.join ":" prepend_path)
              ++ ":\"${PATH:-}\"",
          ])
        (if prepend_pkg_config_path == [] then
          []
        else
          [
            "export PKG_CONFIG_PATH="
              ++ shell_quote (std.string.join ":" prepend_pkg_config_path)
              ++ ":\"${PKG_CONFIG_PATH:-}\"",
          ]))
      (std.array.concat
        (if prepend_cflags == [] then
          []
        else
          [
            "export CFLAGS="
              ++ shell_quote (std.string.join " " prepend_cflags)
              ++ "\"${CFLAGS:+ ${CFLAGS}}\"",
          ])
        (std.array.concat
          (if prepend_cppflags == [] then
            []
          else
            [
              "export CPPFLAGS="
                ++ shell_quote (std.string.join " " prepend_cppflags)
                ++ "\"${CPPFLAGS:+ ${CPPFLAGS}}\"",
            ])
          (if prepend_ldflags == [] then
            []
          else
            [
              "export LDFLAGS="
                ++ shell_quote (std.string.join " " prepend_ldflags)
                ++ "\"${LDFLAGS:+ ${LDFLAGS}}\"",
            ])))
    in
    let pre_lines = if pre_configure == "" then [] else [pre_configure] in
    let post_lines = if post_install == "" then [] else [post_install] in
    let base_lines = [
      "#!/usr/bin/env bash",
      "set -euo pipefail",
      "",
      "src=\"${MBUILD_SOURCE_INPUT:?MBUILD_SOURCE_INPUT is required}\"",
      "out=\"${MBUILD_PRIMARY_OUTPUT:?MBUILD_PRIMARY_OUTPUT is required}\"",
      "",
      "cd \"/in/${src}\"",
      "",
    ] in
    let configure_search_lines = [
      "if [ ! -x ./configure ]; then",
      "  candidates=\"\"",
      "  for d in ./*; do",
      "    if [ -d \"$d\" ] && [ -x \"$d/configure\" ]; then",
      "      candidates=\"$candidates $d\"",
      "    fi",
      "  done",
      "",
      "  set -- $candidates",
      "  if [ \"$#\" -eq 1 ]; then",
      "    cd \"$1\"",
      "  fi",
      "fi",
      "",
    ] in
    let autoreconf_lines =
      if autoreconf then
        [
          "if [ -x ./autogen.sh ]; then ./autogen.sh; fi",
          "if [ -x ./bootstrap ]; then ./bootstrap; fi",
          append_args "autoreconf" autoreconf_args,
          "",
        ]
      else
        []
    in
    let configure_check_lines = [
      "if [ ! -x ./configure ]; then",
      "  echo \"autotools build-script: ./configure not found in /in/${src}\" >&2",
      "  exit 1",
      "fi",
      "",
    ] in
    let build_dir_lines =
      if in_source then
        []
      else
        [
          "mkdir -p " ++ shell_quote build_dir,
          "cd " ++ shell_quote build_dir,
          "",
        ]
    in
    let build_lines = [
      "jobs=\"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)\"",
    ] in
    let command_lines = [
      configure_cmd,
      make_cmd,
      install_cmd,
    ] in
    {
      type = "text",
      artifact_kind = "build-script",
      outputs = [output],
      source =
        std.string.join "\n"
          (
            std.array.concat
              (std.array.concat
                (std.array.concat
                  (std.array.concat
                    (std.array.concat
                      (std.array.concat
                        (std.array.concat
                          (std.array.concat
                            (std.array.concat base_lines prepend_lines)
                            env_lines
                          )
                          configure_search_lines
                        )
                        autoreconf_lines
                      )
                      configure_check_lines
                    )
                    pre_lines
                  )
                  build_dir_lines
                )
                build_lines
              )
              (std.array.concat command_lines post_lines)
          )
        ++ "\n",
    },
}
