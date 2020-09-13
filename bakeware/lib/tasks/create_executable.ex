defmodule Mix.Tasks.CreateExecutable do
  use Mix.Task

  @switches [
    launcher: :string
  ]

  def run(args) do
    case OptionParser.parse(args, strict: @switches) do
      {opts, [path, output], _} ->
        tmp_name = "/tmp/bakeware-gen-#{:crypto.strong_rand_bytes(16) |> Base.encode16()}"

        %{launcher: nil, cpio: "#{tmp_name}.cpio", trailer: "#{tmp_name}.trailer"}
        |> select_launcher(opts)
        |> add_start_script(path)
        |> build_cpio(path)
        |> build_trailer()
        |> concat_files(output)
        |> cleanup_files()

      _ ->
        IO.puts(
          "#{IO.ANSI.red()}Create Executable requires a input and output paths#{
            IO.ANSI.default_color()
          }"
        )
    end
  end

  defp add_start_script(state, path) do
    start_path = Path.join(path, "start") |> Path.expand()
    start_script_path = "bin/simple_app"

    script = """
    #!/bin/sh
    SELF=$(readlink "$0" || true)
    if [ -z "$SELF" ]; then SELF="$0"; fi
    ROOT="$(cd "$(dirname "$SELF")" && pwd -P)"

    $ROOT/#{start_script_path} start
    """

    File.write!(start_path, script)
    File.chmod!(start_path, 0o755)

    state
  end

  defp build_cpio(state, path) do
    path = Path.expand(path)
    # Use MuonTrap for piping? ¬
    _ = :os.cmd('cd #{path} && find . | cpio -o -H newc -v > #{state.cpio}')
    state
  end

  defp build_trailer(state) do
    # maybe stream here to be more efficient
    hash = :crypto.hash(:sha256, File.read!(state.cpio))
    offset = File.stat!(state.launcher).size
    cpio_size = File.stat!(state.cpio).size

    trailer_bin = <<hash::binary, cpio_size::32, offset::32, 0::16, 0::8, 1::8, "BAKE">>
    File.write!(state.trailer, trailer_bin)
    state
  end

  defp cleanup_files(state) do
    _ = File.rm_rf!(state.cpio)
    _ = File.rm_rf!(state.trailer)
  end

  defp concat_files(state, output) do
    output = Path.expand(output)
    _ = :os.cmd('cat #{state.launcher} #{state.cpio} #{state.trailer} > #{output}')
    File.chmod!(output, 0o755)
    IO.puts("#{IO.ANSI.green()}Created #{output}#{IO.ANSI.default_color()}")
    state
  end

  defp select_launcher(state, opts) do
    if opts[:launcher] && File.exists?(opts[:launcher]) do
      %{state | launcher: opts[:launcher]}
    else
      %{state | launcher: Path.join(:code.priv_dir(:bakeware), "launcher")}
    end
  end
end
