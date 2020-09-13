# SimpleApp

This is a Hello World project that's more of a traditional OTP application. All
of the code is in `lib/simple_app/application.ex`. Normally, the idea would be
that this would start up some GenServers running and run for a while. This
example prints out a message and exits.

## Building and running

Change to this directory and run the following:

```sh
export MIX_ENV=prod
mix deps.get
mix release
```

The executable is in the `_build/prod/rel/bakeware` directory. Here's what it
should look like when you run it:

```sh
$ _build/prod/rel/bakeware/simple_app
Hello, OTP Application!
Exiting...
```
