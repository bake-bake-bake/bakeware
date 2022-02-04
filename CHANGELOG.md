# Changelog

## v0.2.3

### Added

- reduce Makefile prints

### Fixed

- Fix mkdir on windows (#128 - thanks @Fl4m3Ph03n1x)
- Use initial 'for' loop delcarations for systems without C99 mode set

## v0.2.2

### Fixed

- Allow spaces in bakeware path within start.bat
- Fix windows path when compressing

## v0.2.1

### Fixed

- Compilation for Windows MinGW users

## v0.2.0

Breaking Changes:

* Applicable release options in `mix.exs` are now scoped to a `:bakeware` key.
  If you were setting `:compression_level` previously, you will need to update
  you setting.

Enhancements:

* Windows Support! (Thanks @kritarthh :tada:) - See [Building on Windows](https://hexdocs.pm/bakeware/readme.html#building-on-windows)
  for more info
* Adds the `:start_command` option to the bakeware `mix` release options
  which allows you to start the bakeware executable with the same commands
  supported by `Mix.Release`. See the bakeware iex_prompt example for how
  this is used so that the IEx prompt supports line editing.
* Adds the `--bw-command`  option when running the executable. See [`mix release` command options](https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-bin-release_name-commands).
* Instructions added for compiling static OpenSSL when needed (thanks @vans163)

Bug Fixes:

* Removes `mix bakeware.assemble` task which is unused and broken (Thanks @christhekeele).
  Please use `mix release` for the same effect

## v0.1.5

Bug fixes:

* Fix an archive creation error that would result in an archive that would fail
  to unpack.
* Fix a segfault when passing an internal command line parameter to the archive

## v0.1.4

This release doesn't change much externally. Internally, we've started cleaning
up the code and adding tests to make Bakeware easier for us to maintain. If you
have existing Bakeware projects, you may also be interested in our example
updates to turn off Erlang distribution and remove the verbose mix release
instructions.

Bug fixes:

* Running the same Bakeware archive at or near the same time now works.
  Previously, it was possible for multiple instances to collide when
  extracting.

## v0.1.3

Bug fixes:

* Fix hex package to include zstd source.

## v0.1.2

Bug fixes:

* Fix script startup crash when testing locally (#66)

## v0.1.1

Initial release to hex.

This release is ok for experimentation, but it not intended for production use.
It has known issues with script and extraction cache handling.
