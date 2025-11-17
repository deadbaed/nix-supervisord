{
  lib,
  pkgs,
  project_name,
  paths,
}:

let
  # TODO: find a way to simplify this naming scheme
  commandName = project: program: "supervisord-${project}-${program}";

  # TODO: find a better way to handle types
  programType =
    {
      name,
      command,
      environment,
    }:
    assert builtins.typeOf name == "string";
    assert builtins.typeOf command == "string";
    assert builtins.typeOf environment == "set";
    {
      inherit name command environment;
    };

  # Create data folder before launching program
  wrapCommand =
    {
      name,
      command,
      dataDir,
    }:
    pkgs.writeShellScriptBin (commandName project_name name) ''
      mkdir -p ${dataDir}
      exec ${command}
    '';

  # Convert environment attrset to supervisord format: var1="value1",var2="value2"
  formatEnvironment = env: lib.concatStringsSep "," (lib.mapAttrsToList (k: v: ''${k}="${v}"'') env);

  # Generate a single program configuration file
  mkProgramConfig =
    {
      name,
      command,
      environment ? { },
    }:
    let
      supervisordEnvironment = environment // {
        SUPERVISORD_ROOT = "${paths.path.root}";
        SUPERVISORD_RUN = "${paths.path.root}/${paths.path.run}";
        SUPERVISORD_DATA = "${paths.path.root}/${paths.path.data}";
        SUPERVISORD_LOG = "${paths.path.root}/${paths.path.log}";
      };
      wrappedCommand = wrapCommand {
        inherit name command;
        dataDir = "${paths.path.data}/${name}";
      };
      envLine = "environment = ${formatEnvironment supervisordEnvironment}";
      program = commandName project_name name;
    in
    pkgs.writeTextFile {
      name = "${program}.conf";
      text = ''
        [program:${name}]
        command = ${wrappedCommand}/bin/${program}
        ${envLine}
      '';
    };

  # TODO: simplify the way arguments are validated
  mkSupervisordProgram =
    config:
    let
      # Validate the input against programType
      validated = programType {
        name = config.name;
        command = config.command;
        environment = config.environment or { };
      };
    in
    mkProgramConfig {
      name = validated.name;
      command = validated.command;
      environment = validated.environment;
    };
in
mkSupervisordProgram
