# C Stuff

I want to move this code over to the `bakeware` directory, but didn't want to
deal with elixir_make yet.

## Commandline arguments

In general, commandline arguments passed to Bakeware applications are passed through to Elixir. A few special commandline arguments can be passed to adjust the launchers behavior. Bakeware stops parsing commandline arguments when it encounters a `--`. Processed commandline arguments are not passed along to Elixir.

The following arguments may be passed:

* `--bw-gc` - This cleans up all unused entries in the cache (NOT IMPLEMENTED)
* `--bw-install` - Do not run the application. Stop after installing to the cache directory. (NOT IMPLEMENTED)
* `--bw-system-install` - Install to a system-wide location (NOT IMPLEMENTED)

## Details

Bakeware application binaries look like this:

* Bakeware application runner
* A CPIO archive of an Erlang/OTP release
* Trailer



Bakeware applications all have the following trailer