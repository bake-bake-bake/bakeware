# NifScript

This example shows how one would build a NIF in a Bakeware executable

## Building and running

Change to this directory and run the following:

```sh
export MIX_ENV=prod
mix deps.get
mix release
```

The executable is in the `_build/prod/rel/bakeware` directory. Here's what it
should look like when you run it

```sh
$ _build/prod/rel/bakeware/nif_script 2 2
2 + 2 = 4
```
