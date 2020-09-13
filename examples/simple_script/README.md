# SimpleScript

This example shows how one would change the [escript example at Elixir
Schools](https://elixirschool.com/en/lessons/advanced/escripts/) to compile to a
Bakeware executable.

This script prints its commandline arguments to the console and if you pass it
`--upcase`, it will convert them to upper case.

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
$ _build/prod/rel/bakeware/simple_script Hello
Hello
$ _build/prod/rel/bakeware/simple_script --upcase Hello
HELLO
```
