{
  pkgs,
  package ? pkgs.python313Packages.supervisor,
}:
let
  mkPaths =
    {
      project ? ".",
      folder ? ".supervisor",
    }:
    import ./paths.nix { inherit project folder; };

  mkSupervisordProgram =
    { project_name, paths }: import ./program.nix { inherit pkgs project_name paths; };

  mkSupervisor =
    {
      project_name,
      paths,
      programs,
    }:
    let
      # Create programs config
      mkProgram = mkSupervisordProgram { inherit project_name paths; };
      programConfigs = map mkProgram programs;

      # Assemble supervisord config + programs
      config = import ./config.nix {
        inherit pkgs project_name paths;
        programs = programConfigs;
      };

      # Expose env variables for programs
      shellHook = ''
        ${paths.env.project}=$(realpath ${paths.path.project})
        ${paths.env.root}=$(realpath ${paths.path.root})
        ${paths.env.run}=$(realpath ${paths.path.root})/${paths.name.run}
        ${paths.env.data}=$(realpath ${paths.path.root})/${paths.name.data}
        ${paths.env.log}=$(realpath ${paths.path.root})/${paths.name.log}

        export ${paths.env.project}
        export ${paths.env.root}
        export ${paths.env.run}
        export ${paths.env.data}
        export ${paths.env.log}
      '';

      supervisord-wrapper = pkgs.writeShellScriptBin "supervisord" ''
        # Make sure required folders exist
        mkdir -p ${paths.path.run} ${paths.path.data} ${paths.path.log}

        # env variables
        ${shellHook}

        # Start supervisord
        ${package}/bin/supervisord -c ${config.configFile}
      '';
      supervisorctl-wrapper = pkgs.writeShellScriptBin "supervisorctl" ''
        ${package}/bin/supervisorctl -c ${config.configFile} "$@"
      '';
      supervisord-kill = pkgs.writeShellScriptBin "supervisord-kill" ''
        kill -s TERM "$(cat ${config.supervisord_process})"
      '';
    in
    {
      inherit
        supervisord-wrapper
        supervisorctl-wrapper
        supervisord-kill
        shellHook
        ;
      paths = paths;
      configFile = config.configFile;
    };
in
{
  inherit mkSupervisor mkPaths;
}
