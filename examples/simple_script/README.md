# SimpleScript

This is a Hello World script that looks like an escript, but compiles down to an
executable that runs on systems without needing to install Erlang. It can even
include NIFS and Ports, but more on that in the `ScriptWithANIF` example.

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
$ _build/prod/rel/bakeware/simple_script
ARGC _main: 0
ARGV _main: []
argc=0
arg0=/home/connor/workspace/bakeware/examples/simple_script/_build/prod/rel/bakeware/simple_script
```

```sh
$ _build/prod/rel/bakeware/simple_script some arguments that will be printed
ARGC _main: 0
ARGV _main: []
argc=0
arg0=/home/connor/workspace/bakeware/examples/simple_script/_build/dev/rel/bakeware/simple_script
arg1=some
arg2=arguments
arg3=that
arg4=will
arg5=be
arg6=printed
```
