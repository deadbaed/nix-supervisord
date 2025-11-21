{
  pkgs,
  project_name,
  paths,
}:
let
  mailpit = "mailpit";
  caddyConfig = pkgs.writeTextFile {
    name = "Caddyfile-${project_name}";
    text = ''
      http://supervisord.localhost:8080 {
        reverse_proxy unix/{env.SUPERVISORD_RUN}/${mailpit}/${mailpit}.sock
      }
    '';
  };
in
# Define the programs to be supervised
[

  # Mailpit is a simple tool to send test emails
  {
    name = mailpit;
    command = "${pkgs.mailpit}/bin/mailpit --db-file ${paths.path.data}/${mailpit}/db.sqlite --listen unix:${paths.path.run}/${mailpit}/${mailpit}.sock:666 --smtp 127.0.0.1:1025 --disable-version-check --label=${project_name}";
  }

  # Caddy is a reverse proxy, configured to view Mailpit's web interface
  (
    let
      name = "caddy";
      config = {
        inherit name;
        command = "${pkgs.caddy}/bin/caddy run --pidfile ${paths.path.run}/${name}/${name}.pid --adapter caddyfile -c ${caddyConfig}";
        environment = {
          XDG_DATA_HOME = "${paths.path.data}/${name}/data";
          XDG_CONFIG_HOME = "${paths.path.data}/${name}/config";
        };
      };
    in
    config
  )
]
