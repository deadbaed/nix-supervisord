{
  lib,
  pkgs,
  project_name,
  paths,
  programs,
}:

let
  config = import ./config.nix {
    inherit
      lib
      pkgs
      project_name
      paths
      programs
      ;
  };
  configFile = config.configFile;
  package = pkgs.python313Packages.supervisor;

  supervisord-wrapper = pkgs.writeShellScriptBin "supervisord" ''
    mkdir -p ${paths.run} ${paths.data} ${paths.log}
    ${package}/bin/supervisord -c ${configFile}
  '';

  supervisorctl-wrapper = pkgs.writeShellScriptBin "supervisorctl" ''
    ${package}/bin/supervisorctl -c ${configFile} $@
  '';

  supervisord-stop = pkgs.writeShellScriptBin "supervisord-stop" ''
    kill -s TERM $(cat ${config.supervisord_process})
  '';
in
{
  inherit supervisord-wrapper supervisorctl-wrapper supervisord-stop;
}
