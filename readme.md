# nix-supervisord

Declare your [supervisord](https://supervisord.org) config and programs with nix!

## Features

- Leverage nixpkgs for the wide selection of fresh packages
- Manage services with a CLI (start/stop/restart) with `supervisorctl`
- Collect unmodified logs in a single place, ready to be processed them with a tool like [lnav](https://lnav.org) (my favorite one)
- Cross platform (Darwin, Linux)

## Get started

A complete example can be found it the folder [example](./example/).

### flakes

I do not know how to do that, if you know please fill this section!

### channels

```shell
nix-channel --add https://github.com/deadbaed/nix-supervisord/archive/master.tar.gz nix-supervisord
nix-channel --update
```

You can use `<nix-supervisord>` as an argument in your nix files.

### npins

Initialize [npins](https://github.com/andir/npins), inside a `nix-shell -p npins`:
```
npins init
npins add github deadbaed nix-supervisord # latest release
npins add github deadbaed nix-supervisord -b master # latest development version
```

Create a `shell.nix` file to define programs, generate your supervisord project and have it in your `PATH`:
```nix
{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
  supervisord ? import sources.nix-supervisord { inherit pkgs; },
}:

let
  project_name = "my_project";
  paths = supervisord.mkPaths { };
  programs = [
    # https://mailpit.axllent.org
    (
      let
        name = "mailpit";
        config = {
          inherit name;
          command = "${pkgs.mailpit}/bin/mailpit --db-file ${paths.path.data}/${name}/db.sqlite --disable-version-check";
          environment = {
            MP_LABEL = "${project_name}";
          };
          pre_commands = [
            "echo \"about to launch mailpit\""
            "echo \"please standby...\""
          ];
        };
      in
      config
    )
  ];
  supervisordProject = supervisord.mkSupervisor { inherit project_name paths programs; };

in
pkgs.mkShellNoCC {
  packages = [
    pkgs.npins
    supervisordProject.supervisord-wrapper
    supervisordProject.supervisorctl-wrapper
    supervisordProject.supervisord-kill
  ];
  shellHook = supervisordProject.shellHook;
}
```

Run `nix-shell .` to enter inside your newly created supervisord environement. [Direnv](https://direnv.net) can be used to be inside the nix shell automatically.

You can:
- Launch the supervised processes with `supervisord`
- Manage everything  with `supervisorctl`
- Kill supervisord with `supervisord-kill`

Files will be stored in `.supervisor`:
- Logs will be in `.supervisor/logs`
- Programs data will be in `.supervisor/data`
- Runtime files such as sockets, pid files will be in `.supervisor/run`

## Why

A project I am working on needs multiple services to run during development. I do not want to remember to launch services individually, or how to launch them for that matter.

After discovering [supervisord](https://supervisord.org) and writing my first config, I got a prototype working in a couple of days to use nix to generate configuration files.
I wanted to extract the config generation logic out of my project and get more nix experience, so I decided to learn how to write a nix library!

## Development

Use [direnv](https://direnv.net) to be inside the nix shell automatically:
```shell
cp .envrc.sample .envrc
direnv allow
```

The source files can be formatted with `treefmt`, it will be checked in CI.
