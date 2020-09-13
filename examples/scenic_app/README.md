# ScenicApp

[Scenic](https://github.com/boydm/scenic) is a GUI framework for Elixir. This is
the default new project application with modifications to support Bakeware.

## Building and running

Building requires a number of libraries and their development header files. See
the [Scenic installation
guide](https://hexdocs.pm/scenic/install_dependencies.html#content).

You'll also need to install `glfw` and `glew` libraries to be able to run:

**MacOS**

```sh
brew install glfw3 glew pkg-config
```

**Ubuntu**

```sh
apt-get install pkgconf libglfw3 libglfw3-dev libglew2.1 libglew-dev
```

After you've worked through that, change to this directory and run the following:

```sh
export MIX_ENV=prod
mix deps.get
mix release
```

The executable is in the `_build/prod/rel/bakeware` directory. Here's what it
should look like when you run it:

```sh
$ _build/prod/rel/bakeware/scenic_app
Many debug prints and a GUI window should pop up...
```

Importantly, you'll be able to copy `scenic_app` to other systems without them
needing Erlang or the development libraries installed. You'll still need the
`glfw` and `glew` shared libraries, but if you wanted to bundle those inside the
`scenic_app` binary, you could. This would require a custom Mix release step to
copy those shared libraries to the release directory, and some work would be
needed to make sure that they're in the shared library search path.
