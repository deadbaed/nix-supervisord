{
  sources ? import ../npins,
  pkgs ? import sources.nixpkgs { },
  lib ? pkgs.lib,
  supervisor ? import ../lib { inherit pkgs; },
}:

let
  # Define your project name
  project_name = "nix-supervisord-example";

  # The default folder where everything will be stored is ".supervisor"
  # For this example "supervisord-files" is used
  folder = "supervisord-files";
  paths = supervisor.mkPaths { inherit folder; };

  # Import programs to be supervised
  programs = import ./programs.nix {
    inherit
      pkgs
      project_name
      paths
      ;
  };

  # Generate all the config files
  supervisordProject = supervisor.mkSupervisor {
    inherit project_name paths programs;
  };
in
rec {
  shell = pkgs.mkShellNoCC {
    buildInputs = with pkgs; [

      # Launch programs and supervisord, available as "supervisord" in PATH
      supervisordProject.supervisord-wrapper

      # CLI to control supervisord and running programs, available as "supervisorctl" in PATH
      supervisordProject.supervisorctl-wrapper

      # Script to kill supervisord, available as "supervisord-kill" in PATH
      supervisordProject.supervisord-kill

      # Tool to view logs, launch with `lnav <log-folder>`
      lnav
    ];
  };
}
