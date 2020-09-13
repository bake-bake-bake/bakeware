# SimpleEval

This example shows how one would evaluate a string on the command line.

## Building and running

Change to this directory and run the following:

```sh
export MIX_ENV=prod
mix deps.get
mix release
```

The executable is in the `_build/prod/rel/bakeware` directory. Here's what it
should look like when you run it with no arguments:

```sh
$ _build/prod/rel/bakeware/simple_eval "IO.puts(\"hello, world\")"
hello, world
```
