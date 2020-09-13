# SimpleApp

This is a Hello World project that's more of a traditional OTP application. All
of the code is in `lib/simple_app/application.ex`. Normally, the idea would be
that this would start up some GenServers running and run for a while. This
example prints out a message and exits.

## Building

```sh
export MIX_ENV=prod
mix deps.get
mix release
mix create_executable _build/prod/rel/simple_app simple_app
```

