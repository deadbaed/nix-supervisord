{
  pkgs,
  project_name,
  paths,
}:

let
  inherit (pkgs.lib) types throwIfNot;

  formatSupervisordCommand = project: program: "supervisord-${project}-${program}";

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

  mkSupervisordProgram =
    config:
    let
      name = config.name;
      command = config.command;
      pre_commands = config.pre_commands or [ ];
      environment = config.environment or { };

      # Validate types
      validName = throwIfNot (types.str.check name) "mkSupervisordProgram: 'name' must be a string, got: ${builtins.typeOf name}";
      validCommand = throwIfNot (types.str.check command) "mkSupervisordProgram: 'command' must be a string, got: ${builtins.typeOf command}";
      validPreCommands = throwIfNot ((types.listOf types.str).check pre_commands) "mkSupervisordProgram: 'pre_commands' must be a list of strings, got: ${builtins.typeOf pre_commands}";
      validEnvironment = throwIfNot ((types.attrsOf types.str).check environment) "mkSupervisordProgram: 'environment' must be an attribute set of strings, got: ${builtins.typeOf environment}";
    in
    validName validCommand validPreCommands validEnvironment mkProgramConfig {
      inherit
        name
        command
        pre_commands
        environment
        ;
    };
in
mkSupervisordProgram
