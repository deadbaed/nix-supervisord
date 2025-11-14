{
  sources ? import ../npins,
  pkgs ? import sources.nixpkgs { },
}:

let
  # nixpkgs
  lib = pkgs.lib;

  # Define your project name
  project_name = "nix-supervisord-example";

  # The default folder where everything will be stored is ".supervisor"
  # For this example "supervisord-files" is used
  paths = import ../supervisor/paths.nix { folder = "supervisord-files"; };

  # Import programs to be supervised
  programs = import ./programs.nix {
    inherit
      lib
      pkgs
      project_name
      paths
      ;
  };

  # Generate all the config files
  supervisor = import ../supervisor {
    inherit
      lib
      pkgs
      project_name
      paths
      programs
      ;
  };
in
rec {
  shell = pkgs.mkShellNoCC {
    buildInputs = with pkgs; [

      # Launch programs and supervisord, available as "supervisord" in PATH
      supervisor.supervisord-wrapper

      # CLI to control supervisord and running programs, available as "supervisorctl" in PATH
      supervisor.supervisorctl-wrapper

      # Script to kill supervisord, available as "supervisord-stop" in PATH
      supervisor.supervisord-stop

      # Tool to view logs, launch with `lnav <log-folder>`
      lnav
    ];
  };
}
