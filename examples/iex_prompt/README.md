# IExPrompt

This example shows one way of making a self-contained binary that starts up an
IEx prompt.

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
$ _build/prod/rel/bakeware/iex_prompt
iex(iex_prompt@localhost)1> IO.puts("hello, world")
hello, world
:ok
iex(iex_prompt@localhost)2>
```
