defmodule Bakeware.Assembler do
  @moduledoc false
  defstruct [
    :start_command,
    :compress?,
    :compression_level,
    :cpio,
    :launcher,
    :name,
    :output,
    :path,
    :release,
    :rel_path,
    :trailer
  ]

  @type t() :: %__MODULE__{
          start_command: binary(),
          compress?: boolean(),
          compression_level: 1..19,
          cpio: Path.t(),
          launcher: Path.t(),
          name: String.t(),
          output: Path.t(),
          path: Path.t(),
          release: Mix.Release.t(),
          rel_path: Path.t(),
          trailer: Path.t()
        }

  alias Bakeware.CPIO

  @doc false
  @spec assemble(Mix.Release.t()) :: Mix.Release.t()
  def assemble(%Mix.Release{} = release) do
    %__MODULE__{name: release.name, rel_path: release.path, release: release}
    |> do_assemble()
    # Assembler requires %Mix.Release{} struct returned
    |> Map.get(:release)
  end

  @doc false
  @spec assemble(Path.t(), String.t()) :: Mix.Release.t()
  def assemble(path, name) do
    %__MODULE__{name: name, rel_path: Path.expand(path)}
    |> do_assemble()
    |> Map.get(:release)
  end

  defp create_paths(assembler) do
    bake_path = Path.dirname(assembler.rel_path) |> Path.join("bakeware")
    tmp_name = :crypto.strong_rand_bytes(16) |> Base.encode16()

    _ = File.mkdir_p!(bake_path)

    %{
      assembler
      | path: bake_path,
        cpio: Path.join(bake_path, "#{tmp_name}.cpio"),
        launcher: Application.app_dir(:bakeware, ["launcher", "launcher"]),
        output:
          Path.join(
            bake_path,
            "#{assembler.name}#{
              case :os.type(),
                do:
                  (
                    {:win32, _} -> ".exe"
                    _ -> ""
                  )
            }"
          ),
        trailer: Path.join(bake_path, "#{tmp_name}.trailer")
    }
  end

  defp do_assemble(assembler) do
    IO.puts("""
    #{IO.ANSI.green()}* assembling#{IO.ANSI.default_color()} bakeware #{assembler.name}
    """)

    assembler
    |> create_paths()
    |> set_compression()
    |> set_start_command()
    |> add_start_script()
    |> add_start_batch()
    |> CPIO.build()
    |> build_trailer()
    |> concat_files()
    |> cleanup_files()
  end

  defp add_start_script(assembler) do
    start_path = Path.join(assembler.rel_path, "start")
    start_script_path = "bin/#{assembler.name}"

    script = """
    #!/bin/sh
    SELF=$(readlink "$0" || true)
    if [ -z "$SELF" ]; then SELF="$0"; fi
    ROOT="$(cd "$(dirname "$SELF")" && pwd -P)"

    $ROOT/#{start_script_path} $1
    """

    File.write!(start_path, script)
    File.chmod!(start_path, 0o755)

    assembler
  end

  defp add_start_batch(assembler) do
    start_path = Path.join(assembler.rel_path, "start.bat")
    start_script_path = "bin/#{assembler.name}"

    script = """
    @echo off
    setlocal enabledelayedexpansion

    set ROOT=%~dp0
    %ROOT%/#{start_script_path} %1
    """

    File.write!(start_path, script)
    File.chmod!(start_path, 0o755)

    assembler
  end

  defp build_trailer(assembler) do
    # maybe stream here to be more efficient
    hash = :crypto.hash(:sha, File.read!(assembler.cpio))
    cmd_len = byte_size(assembler.start_command)
    cmd_padding = :binary.copy(<<0>>, 12 - cmd_len)
    offset = File.stat!(assembler.launcher).size
    cpio_size = File.stat!(assembler.cpio).size

    compression = if assembler.compress?, do: 1, else: 0
    trailer_version = 1
    flags = 0

    trailer_bin =
      <<hash::20-bytes, assembler.start_command::binary, cmd_padding::binary, cpio_size::32,
        offset::32, flags::16, compression::8, trailer_version::8, "BAKE">>

    File.write!(assembler.trailer, trailer_bin)
    assembler
  end

  defp cleanup_files(assembler) do
    _ = File.rm_rf!(assembler.cpio)
    _ = File.rm_rf!(assembler.trailer)

    IO.puts("Bakeware successfully assembled executable at:\n")
    IO.puts("    #{Path.relative_to(assembler.output, File.cwd!())}")

    assembler
  end

  defp concat_files(assembler) do
    _ =
      :os.cmd(
        'cat #{assembler.launcher} #{assembler.cpio} #{assembler.trailer} > #{assembler.output}'
      )

    File.chmod!(assembler.output, 0o755)
    assembler
  end

  defp set_compression(assembler) do
    ##
    # TODO: Make compression required and move this
    compress? =
      case System.find_executable("zstd") do
        nil ->
          # no compression
          IO.puts("""
          #{IO.ANSI.yellow()}* warning#{IO.ANSI.default_color()} [Bakeware] zstd not installed. Skipping compression...
          """)

          false

        _path ->
          true
      end

    check_invalid_option!(assembler.release, :compression_level)

    compression_level = assembler.release.options[:bakeware][:compression_level] || 15

    if compression_level not in 1..19 do
      Mix.raise(
        "[Bakeware] invalid zstd compression level - Must be an integer 1-19. Got: #{
          inspect(compression_level)
        }"
      )
    end

    %{assembler | compression_level: compression_level, compress?: compress?}
  end

  defp set_start_command(assembler) do
    check_invalid_option!(assembler.release, :start_command)
    command = assembler.release.options[:bakeware][:start_command] || "start"
    cmd_len = byte_size(command)

    if cmd_len > 12 do
      err = """
      [Bakeware] invalid start command. See the mix release documentation for options

        https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-bin-release_name-commands
      """

      Mix.raise(err)
    end

    %{assembler | start_command: command}
  end

  defp check_invalid_option!(release, option) do
    if value = release.options[option] do
      Mix.raise("""
      [Bakeware] setting :#{option} in the release options outside of the :bakeware key is no longer supported.

      Please adjust your release options in mix.exs to continue:

        def release do
          [
            ...
            steps: [&Bakeware.assemble/1, :assemble],
            bakeware: [#{option}: #{inspect(value)}]
            ...
          ]
        end
      """)
    end

    :ok
  end
end
