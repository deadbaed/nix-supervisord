{
  project ? ".",
  folder ? ".supervisor",
}:
let
  root = "${project}/${folder}";
in
{
  path = {
    inherit project root;
    run = "${root}/run";
    data = "${root}/data";
    log = "${root}/log";
  };
  env = {
    project = "SUPERVISORD_PROJECT";
    root = "SUPERVISORD_ROOT";
    run = "SUPERVISORD_RUN";
    data = "SUPERVISORD_DATA";
    log = "SUPERVISORD_LOG";
  };
}
