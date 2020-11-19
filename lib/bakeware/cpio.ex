defmodule Bakeware.CPIO do
  alias Bakeware.Assembler

  @cpio_magic "070701"

  def build(%Assembler{} = assembler) do
    File.open(assembler.cpio, [:write, :append], fn cpio_fd ->
      _ = append_files(assembler.rel_path, cpio_fd)
      _ = append_trailer(cpio_fd)
    end)

    _ = maybe_compress(assembler)

    assembler
  end

  defp append_files(release_path, cpio_fd) do
    for path <- Path.wildcard("#{release_path}/**/*"), path != release_path do
      file = file_details(path, release_path)

      # write CPIO header
      IO.binwrite(cpio_fd, build_header(file.mode, file.size, file.relative_path))

      maybe_write_file_contents(file, cpio_fd)
    end
  end

  defp append_trailer(fd) do
    IO.binwrite(fd, build_header(0, 0, "TRAILER!!!"))
  end

  defp build_header(mode, size, relative) do
    namesize = byte_size(relative)

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
      pad_hex(namesize + 1),
      zero(),
      relative,
      # Null terminator on path
      0,
      pad_to_4(110 + namesize + 1)
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
    File.open(file.path, [:read], fn fd ->
      IO.binwrite(cpio_fd, IO.binread(fd, :all))
    end)

    IO.binwrite(cpio_fd, pad_to_4(file.size))
  end

  defp pad_hex(i) do
    hex = Integer.to_string(i, 16)
    pad_size = 8 - byte_size(hex)

    :binary.copy("0", pad_size) <> hex
  end

  defp pad_to_4(length) do
    case Integer.mod(length, 4) do
      0 -> <<>>
      1 -> <<0, 0, 0>>
      2 -> <<0, 0>>
      3 -> <<0>>
    end
  end

  defp zero(), do: "00000000"
end
