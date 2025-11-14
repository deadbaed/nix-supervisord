{
  project ? "./.",
  folder ? ".supervisor",
}:

let
  root = "${project}/${folder}";
  run = "${root}/run";
  data = "${root}/data";
  log = "${root}/log";
in
{
  inherit
    root
    run
    data
    log
    ;
}
