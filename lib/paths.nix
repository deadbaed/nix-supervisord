{
  project ? ".",
  folder ? ".supervisor",
}:
let
  root = "${project}/${folder}";
  run = "run";
  data = "data";
  log = "log";
in
{
  path = {
    inherit project root;
    run = "${root}/${run}";
    data = "${root}/${data}";
    log = "${root}/${log}";
  };
  env = {
    project = "SUPERVISORD_PROJECT";
    root = "SUPERVISORD_ROOT";
    run = "SUPERVISORD_RUN";
    data = "SUPERVISORD_DATA";
    log = "SUPERVISORD_LOG";
  };
  name = {
    inherit run data log;
  };
}
