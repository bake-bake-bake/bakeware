# Bakeware

Compile Elixir applications into single, easily distributed executable binaries

![The Bakeware oven](bakeware/assets/bakeware_logo200.png)

Do you have [Go](https://golang.org/)-envy for how easy it is to distribute
commandline utilities? Or maybe your
[escript](https://hexdocs.pm/mix/1.10.4/Mix.Tasks.Escript.Build.html) grew too
much and you hit a wall with a library that required platform-specific code? Or
that OTP release seemed so easy to distribute, but somehow running untar was
just enough friction to make someone complain about your use of Elixir.

Bakeware addresses these issues by extending [Mix
releases](https://hexdocs.pm/mix/1.10.4/Mix.Tasks.Release.html) with the ability
to turn Elixir projects into single binaries that can be copied and directly
run. No need to install Erlang or untar files. The binaries look and feel like
the build-products from other languages.

Here's a quick list of features:

* Simple - add the `bakeware` dependency and the Bakeware assembler to your Mix
  release settings
* Supports OSX and Linux (We wrote the code with Windows and the BSDs in mind,
  so support for those platforms may not be far off)
* [Zstd compression](https://en.wikipedia.org/wiki/Zstandard) for small binaries
* Optional support for automatic software updates
* Commandline argument passing conveniences
* Lots of examples

Some stats:

* Executables are 12-15 MB on Linux and 5-7 MB on OSX for simple Elixir,
  Phoenix, and Scenic apps (Zstd compression enabled)
* Non-scientifically - ~0.5s startup times or better on our computers (measured
  with `time`)

How does Bakeware work?

Bakeware combines a compressed OTP release archive with a smart
platform-specific self-extractor. The self-extractor expands the OTP release to
a cache on first execution and reuses the cache for subsequent invocations. Due
to the use of Zstd compression, the expansion is very fast and mostly invisible
to the end user.

The best way to try out Bakeware is to clone this repository and try out the
[examples](examples/README.md).

Each example has been preassembled into an executable in the [`examples/bin`](examples/bin)
directory and can be run immediately without further setup. Enter the directory
for your current operating system and run an app. i.e.

```sh
$ cd examples/bin/MacOS
$ ./simple_app
Hello, OTP Application!
Exiting...
```

Documentation is provided in the main [`bakeware`](bakeware/README.md) library,
the examples, and the [`SousCheck`](sous_chef/README.md) software update server.

## Projects

Here's a list of the projects in this repository:

* [`bakeware`](bakeware/README.md) - The main library
* [`examples`](examples/README.md) - Examples
* [`bakeware_updater`](bakeware_updater/README.md) - Small Elixir library to check update server
  for an available update, download it, and apply it to the existing executable
* [`sous_chef`](sous_chef/README.md) - An example update server for binaries built with Bakeware
