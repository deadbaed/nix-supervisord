{
  pkgs,
  project_name,
  paths,
}:

let
  formatSupervisordCommand = project: program: "supervisord-${project}-${program}";

  # TODO: find a better way to handle types
  programType =
    {
      name,
      command,
      pre_commands,
      environment,
    }:
    assert builtins.typeOf name == "string";
    assert builtins.typeOf command == "string";
    assert builtins.typeOf pre_commands == "list";
    assert builtins.typeOf environment == "set";
    {
      inherit
        name
        command
        pre_commands
        environment
        ;
    };

  # Create data folder, run commands before launching final program
  wrapCommand =
    {
      name,
      command,
      pre_commands,
    }:
    pkgs.writeShellScriptBin (formatSupervisordCommand project_name name) ''
      set -e
      mkdir -p ${paths.path.data}/${name} ${paths.path.run}/${name}
      ${pkgs.lib.concatStringsSep "\n" pre_commands}
      exec ${command}
    '';

  # Convert environment attrset to supervisord format: var1="value1",var2="value2"
  formatEnvironment =
    env: pkgs.lib.concatStringsSep "," (pkgs.lib.mapAttrsToList (k: v: ''${k}="${v}"'') env);

  # Generate a single program configuration file
  mkProgramConfig =
    {
      name,
      command,
      pre_commands,
      environment,
    }:
    let
      wrappedCommand = wrapCommand {
        inherit name command pre_commands;
      };
      envLine = pkgs.lib.optionalString (
        environment != { }
      ) "environment = ${formatEnvironment environment}";
      program = formatSupervisordCommand project_name name;
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
        pre_commands = config.pre_commands or [ ];
        environment = config.environment or { };
      };
    in
    mkProgramConfig {
      name = validated.name;
      command = validated.command;
      pre_commands = validated.pre_commands;
      environment = validated.environment;
    };
in
mkSupervisordProgram
