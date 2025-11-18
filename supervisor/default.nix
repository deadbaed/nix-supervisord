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
  root = paths.path.root;

  supervisord-wrapper = pkgs.writeShellScriptBin "supervisord" ''
    mkdir -p ${root}/${paths.path.run} ${root}/${paths.path.data} ${root}/${paths.path.log}
    export ${paths.env.root}=$(realpath ${root})
    export ${paths.env.run}=$(realpath ${root})/${paths.path.run}
    export ${paths.env.data}=$(realpath ${root})/${paths.path.data}
    export ${paths.env.log}=$(realpath ${root})/${paths.path.log}
    ${package}/bin/supervisord -c ${configFile}
  '';

  supervisorctl-wrapper = pkgs.writeShellScriptBin "supervisorctl" ''
    ${package}/bin/supervisorctl -c ${configFile} $@
  '';

  supervisord-kill = pkgs.writeShellScriptBin "supervisord-kill" ''
    kill -s TERM $(cat ${config.supervisord_process})
  '';
in
{
  inherit supervisord-wrapper supervisorctl-wrapper supervisord-kill;
}
