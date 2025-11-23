{
  pkgs,
  project_name,
  paths,
  programs,
}:

let
  # All program config files
  includeSection =
    let
      filePaths = pkgs.lib.concatStringsSep " " programs;
    in
    pkgs.lib.optionalString (programs != [ ]) ''
      [include]
      files = ${filePaths}
    '';

  supervisord_socket = "${paths.path.run}/supervisord.sock";
  supervisord_process = "${paths.path.run}/supervisord.pid";

  # Main supervisord config file https://supervisord.org/configuration.html
  configFile = pkgs.writeTextFile {
    name = "supervisord-${project_name}-config.conf";
    text = ''
      [supervisord]
      pidfile = ${supervisord_process}
      logfile = ${paths.path.log}/supervisord.log
      childlogdir = ${paths.path.log}

      [unix_http_server]
      file = ${supervisord_socket}

      [supervisorctl]
      serverurl = unix://${supervisord_socket}
      prompt = ${project_name}

      [rpcinterface:supervisor]
      supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

      ${includeSection}
    '';
  };
in
{
  inherit configFile supervisord_process;
}
