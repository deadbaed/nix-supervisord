# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

## 0.4.0 - 2026-03-26

### Added

- Declared programs can define the time they take to consider the start successful with `start_secs`. It defines the `startsecs` option in `supervisord`. Value can be set to `0` to define oneshot programs, which will exit right after their execution.

## 0.3.0 - 2025-12-20

### Changed

- Run the scripts `supervisord`, `supervisorctl` and `supervisord-kill` from `$SUPERVISORD_PROJECT`, instead of `$PWD`.

## 0.2.0 - 2025-12-19

### Added

- Expose path of project in `mkPaths` as `paths.path.project` or via the environment variable `SUPERVISORD_PROJECT`.
- Declared programs can run additional commands with `pre_commands` before the final `command` will be executed, as `command` must only take one single command.
- Expose `SUPERVISORD_*` varibles in `mkSupervisor` as `shellHook`.
- Expose raw names of supervisord folders in `mkPaths` as `paths.name.*` (used internally, but still exposed).

### Changed

- The generated supervisord environment starts at the the project level `paths.path.project`, instead of the root of the environment `paths.path.root`.

## 0.1.0 - 2025-11-21

Initial release

