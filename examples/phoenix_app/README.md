# PhoenixApp

This is a barebones Phoenix application with modifications to the `mix.exs` to
use Bakeware.

## Building and running

```sh
export MIX_ENV=prod
mix deps.get
mix phx.digest
mix release
```

The executable is in the `_build/prod/rel/bakeware` directory. Here's what it
should look like when you run it:

```sh
$ _build/prod/rel/bakeware/phoenix_app
14:49:34.654 [info] Running PhoenixAppWeb.Endpoint with cowboy 2.8.0 at :::4000 (http)
14:49:34.655 [info] Access PhoenixAppWeb.Endpoint at http://example.com
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
