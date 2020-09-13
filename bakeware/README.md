# Bakeware

![The Bakeware oven](assets/bakeware_logo200.png)

TBD

## Using

### Mix release

Bakeware supports tieing in executable binary assembly into a Mix release
as a step by using the `Bakeware.assemble/1` function.

<!-- ASSEMBLE !-->
This will assemble the necessary components to create a Bakeware executable
that can be distributed across machines to run the script/application without
extra environment setup (such as installing Elixir/Erlang, etc)

To use, add this to your release as a step after assembly:

```elixir
def release do
  [
    demo: [
      steps: [:assemble, &Bakeware.assemble/1]
    ]
  ]
end
```
<!-- ASSEMBLE !-->

### Mix task

Bakeware also supports manually assembling the executable via `mix bakeware.assemble`

<!-- ASSEMBLE_TASK !-->
Generally, it is expected that you integrate assembly as a Mix release
step (see `Bakeware.assemble/1`)

However, this task provides the ability to manually assemble the bakeware executable
binary either for the current project, or for other specified release directories.

Supported options:

* `--name` - Name to use for the binary. Defaults to the app name
* `--path` - path to release directory. Defaults to release directory
  of current Mix project
<!-- ASSEMBLE_TASK !-->

### Scripting

<!-- SCRIPT !-->
Bakeware supports an API similar to Escript for implementing a `main` function.

The `main` function will take 2 arguments:

* `arg0` - The absolute path to the executable
* `args` - Analogous to argv in other languages. A list or arguments passed to the
  executable

The `main` function must return a superset of functions that :erlang.halt/1 supports:

* integer -> returning an integer will set the exit status. IE success: 0, error: >= 1
* iodata -> An Erlang crash dump is produced with `iodata` as slogan. Then the runtime system exits with status code 1.
  The string will be truncated if longer than 200 characters.
* :abort -> The runtime system aborts producing a core dump, if that is enabled in the OS.

Example:

```elixir
defmodule MyApp.Main do
  use Bakeware.Script
  
  @impl Bakeware.Script
  def main(_arg0, _args) do
    IO.puts "Hello, World!"
    0
  end
end
```
<!-- SCRIPT !-->

## Tips

### Minimizing executable size

Bakeware binaries appear to have a lower bound of about 12 MB in size. We expect
that they can be made smaller out-of-the-box, but here are a few things you can
do:

1. Build using `MIX_ENV=prod`. The default is `MIX_ENV=dev`, so be sure that the
   environment variable is set.
2. Run `rm -fr _build` and then `mix release`. During development cruft builds
   up in the release directory. Bakeware can't tell the difference between the
   important files and the cruft, so executables will slowly grow in size if you
   don't do a clean build.
3. Inspect your `_build/prod/rel/<name>` directory and especially under `lib`
   for files or dependencies that you might be including on accident.
4. Make sure that compile-time dependencies are marked as `runtime: false` in
   your `mix.exs` so that they're not included

### Creating cross-platform binaries

Bakeware binaries include the Erlang runtime but there are still dependencies on
the host system. These include the C runtime and other libraries referenced by
the Erlang runtime and any NIFs and ports in your application. Luckily, the
binary ABIs of many libraries are very stable, but if distributing to a wide
audience, it's useful to build on a system with older library versions. Python
has a useful pointers in their [packaging
guides](https://packaging.python.org/guides/packaging-binary-extensions/#building-binary-extensions).

## Reference material

### Commandline arguments

In general, commandline arguments passed to Bakeware applications are passed through to Elixir. A few special commandline arguments can be passed to adjust the launchers behavior. Bakeware stops parsing commandline arguments when it encounters a `--`. Processed commandline arguments are not passed along to Elixir.

The following arguments may be passed:

* `--bw-info` - Print out information about the application
* `--bw-gc` - This cleans up all unused entries in the cache (NOT IMPLEMENTED)
* `--bw-install` - Do not run the application. Stop after installing to the cache directory. (NOT IMPLEMENTED)
* `--bw-system-install` - Install to a system-wide location (NOT IMPLEMENTED)

### Environment variables

The Bakeware launcher sets the following environment variables for use in Elixir:

Variable name                       | Description
 ---------------------------------- | --------------------------
`BAKEWARE_EXECUTABLE`               | The absolute path to the executable
`BAKEWARE_ARG1`                     | The first commandline argument
`BAKEWARE_ARGn`                     | The nth commandline argument
`BAKEWARE_ARGC`                     | The number of arguments

See the SCRIPT secion of this document for a more user friendly API.

### Binary format

Bakeware application binaries look like this:

* Bakeware application launcher
* A CPIO archive of an Erlang/OTP release
* Trailer

The CPIO archive can be compressed. This depends on the contents of the trailer.

Trailer format (multi-byte fields are big endian):

Offset from end | Field           | Type           | Description
 -------------- | --------------- | -------------- | -----------
-4              | Magic           | 4 byte string  | Set to "BAKE"
-5              | Trailer version | 8-bit integer  | Set to 1
-6              | Compression     | 8-bit integer  | 0 = No compression, 1 = Zstd
-8              | Flags           | 16-bit integer | Set to 0 (no flags yet)
-12             | Contents offset | 32-bit integer | Offset of CPIO archive
-16             | Contents length | 32-bit integer | Length of CPIO archive
-48             | SHA256          | 32 bytes       | SHA-256 of the CPIO archive

## Cache directory

Bakeware maintains a cache of extracted binaries. This is needed to run the
OTP releases and it enables start-time optimizations.

The cache directory location is system-specific:

* Windows - `"C:/Users/<USER>/AppData/Local/Bakeware/cache"`
* macOS - `"~/Library/Caches/Bakeware"`
* Linux and other Unixes - `"~/.cache/bakeware"`

Here's the layout of each cache entry:

Path                                | Created by | Description
 ---------------------------------- | ---------- | --------------------------
`$CACHE_DIR/$SHA256/source_paths`   | Launcher   | A list of source paths (used for GC)
`$CACHE_DIR/$SHA256/bin`            | CPIO       | OTP release's `bin` directory
`$CACHE_DIR/$SHA256/erts-x.y.z`     | CPIO       | OTP release's ERTS
`$CACHE_DIR/$SHA256/lib`            | CPIO       | OTP release's `lib` directory
`$CACHE_DIR/$SHA256/releases`       | CPIO       | OTP release's `releases` directory
`$CACHE_DIR/$SHA256/start`          | CPIO       | Start script. E.g., `bin/my_otp_release start`

TODO: Add lock file to protect an executable being extracted on top of itself.
This might actually work, though...
