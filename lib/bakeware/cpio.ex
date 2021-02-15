defmodule Bakeware.CPIO do
  alias Bakeware.Assembler

  @doc false

  @cpio_magic "070701"

  @spec build(Assembler.t()) :: Assembler.t()
  def build(%Assembler{} = assembler) do
    {:ok, :ok} =
      File.open(assembler.cpio, [:write, :append], fn cpio_fd ->
        :ok = append_files(assembler.rel_path, cpio_fd)
        :ok = append_trailer(cpio_fd)
      end)

    _ = maybe_compress(assembler)

    assembler
  end

  defp append_files(release_path, cpio_fd) do
    Path.wildcard("#{release_path}/**/*")
    |> Enum.each(&append_file(release_path, &1, cpio_fd))

    :ok
  end

  defp append_file(release_path, path, cpio_fd) when release_path != path do
    file = file_details(path, release_path)

    # write CPIO header
    :ok = IO.binwrite(cpio_fd, build_header(file.mode, file.size, file.relative_path))

    maybe_write_file_contents(file, cpio_fd)
  end

  defp append_file(_release_path, _path, _cpio_fd) do
    :ok
  end

  defp append_trailer(fd) do
    IO.binwrite(fd, build_header(0, 0, "TRAILER!!!"))
  end

  defp build_header(mode, size, relative) do
    name_size = byte_size(relative)

    [
      @cpio_magic,
      zero(),
      pad_hex(mode),
      zero(),
      zero(),
      zero(),
      zero(),
      pad_hex(size),
      zero(),
      zero(),
      zero(),
      zero(),
      pad_hex(name_size + 1),
      zero(),
      relative,
      # Null terminator on path
      0
    ]
  end

  defp file_details(path, release_path) do
    File.stat!(path)
    |> Map.from_struct()
    |> Map.put(:path, path)
    |> Map.put(:relative_path, Path.relative_to(path, release_path))
  end

  defp maybe_compress(%{compress?: true} = assembler) do
    out = assembler.cpio <> ".zst"

    {_, 0} =
      System.cmd("zstd", ["-#{assembler.compression_level}", assembler.cpio, "-o", out, "--rm"])

    File.rename(out, assembler.cpio)
  end

  defp maybe_compress(_assembler), do: :ignore

  defp maybe_write_file_contents(%{type: :directory}, _cpio_fd), do: :ignore

  defp maybe_write_file_contents(file, cpio_fd) do
    # Read the file and append to CPIO
    {:ok, :ok} =
      File.open(file.path, [:read], fn fd ->
        IO.binwrite(cpio_fd, IO.binread(fd, :all))
      end)
  end

  defp pad_hex(i) do
    hex = Integer.to_string(i, 16)
    pad_size = 8 - byte_size(hex)

    :binary.copy("0", pad_size) <> hex
  end

  defp zero(), do: "00000000"
end
