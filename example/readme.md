# nix-supervisord example

Simple showcase of nix-supervisord. I used [npins](https://github.com/andir/npins) to pin nixpkgs, but flakes can be used if wanted.

The programs to run are defined in `programs.nix`. In this example, [Caddy](https://caddyserver.com) and [Mailpit](https://mailpit.axllent.org) are defined.

## Get started

Open a nix shell with `nix-shell`. For quick access, use [direnv](https://direnv.net).

With direnv installed, you can run:
```shell
cp .envrc.sample .envrc
direnv allow
```
to be inside the nix shell when you are in the directory.

You can launch the supervised processes with `supervisord`, and control with with `supervisorctl`. Stop the processed with `supervisord-stop`.

When supervisord is running, you should be able to open your web browser to `http://supervisord.localhost` and see Mailpit running.
