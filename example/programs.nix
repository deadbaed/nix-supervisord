{
  lib,
  pkgs,
  project_name,
  paths,
}:
let
  # Import the tool to generate config files for each program
  mkSupervisordProgram = import ../supervisor/program.nix {
    inherit
      lib
      pkgs
      project_name
      paths
      ;
  };

  mailpit = "mailpit";
  mailpitSocket = "${paths.run}/${mailpit}.sock";
  caddyConfig = pkgs.writeTextFile {
    name = "Caddyfile-${project_name}";
    text = ''
      supervisord.localhost:80 {
        reverse_proxy unix/${mailpitSocket}
      }
    '';
  };
in
# Define the programs to be supervised
[

  # Mailpit is a simple tool to send test emails
  (mkSupervisordProgram {
    name = mailpit;
    command = "${pkgs.mailpit}/bin/mailpit --db-file ${paths.data}/${mailpit}/db.sqlite --listen unix:${mailpitSocket}:666 --smtp 127.0.0.1:1025 --disable-version-check --label=${project_name}";
  })

  # Caddy is a reverse proxy, configured to view Mailpit's web interface
  (
    let
      name = "caddy";
      config = {
        inherit name;
        command = "${pkgs.caddy}/bin/caddy run -c ${caddyConfig} --adapter caddyfile --pidfile ${paths.run}/${name}.pid";
        environment = {
          XDG_DATA_HOME = "${paths.data}/${name}/data";
          XDG_CONFIG_HOME = "${paths.data}/${name}/config";
        };
      };
    in
    mkSupervisordProgram config
  )
]
