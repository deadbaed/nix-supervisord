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
    inherit
      root
      run
      data
      log
      ;
  };
  env = {
    root = "$SUPERVISORD_ROOT";
    run = "$SUPERVISORD_RUN";
    data = "$SUPERVISORD_DATA";
    log = "$SUPERVISORD_LOG";
  };
}
