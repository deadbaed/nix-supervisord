{
  project ? ".",
  folder ? ".supervisor",
}:
{
  path = {
    root = "${project}/${folder}";
    run = "run";
    data = "data";
    log = "log";
  };
  env = {
    root = "SUPERVISORD_ROOT";
    run = "SUPERVISORD_RUN";
    data = "SUPERVISORD_DATA";
    log = "SUPERVISORD_LOG";
  };
}
