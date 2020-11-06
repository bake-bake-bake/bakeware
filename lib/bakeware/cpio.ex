defmodule Bakeware.CPIO do
  alias Bakeware.Assembler

  @cpio_magic "070701"

  def build(%Assembler{} = assembler) do
    {:ok, fd} = File.open(assembler.cpio, [:write, :append])

    # TODO: replicate find to avoid shell out
    # Path.wildcard("#{assembler.rel_path}/**/*")
    :os.cmd('find #{assembler.rel_path}')
    |> to_string()
    |> String.split()
    |> Enum.each(&append_cpio(&1, fd, assembler.rel_path))

    append_trailer(fd)

    :ok = File.close(fd)

    if assembler.compress? do
      out = assembler.cpio <> ".z"
      :os.cmd('zstd -15 #{assembler.cpio} -o #{out} --rm')
      File.rename(out, assembler.cpio)
    end

    assembler
  end

  defp append_cpio(path, _fd, release_path) when path == release_path, do: :ignore

  defp append_cpio(path, fd, release_path) do
    stats = File.stat!(path)
    # Must include a null terminating byte
    relative = Path.relative_to(path, release_path)

    IO.binwrite(fd, build_header(stats.mode, stats.size, relative))

    if stats.type != :directory do
      File.open(path, [:read], &append_file(&1, fd))
      IO.binwrite(fd, pad_to_4(stats.size))
    end
  end

  defp append_file(fd, cpio_fd) do
    stuff = IO.binread(fd, :all)
    IO.binwrite(cpio_fd, stuff)
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

  defp pad_hex(i) do
    hex = Integer.to_string(i, 16)
    pad_size = 8 - byte_size(hex)

    if pad_size > 0 do
      pad = for _i <- 1..pad_size, into: "", do: "0"
      pad <> hex
    else
      hex
    end
  end

  defp zero(), do: "00000000"

  defp pad_to_4(length) do
    y =
      case Integer.mod(length, 4) do
        0 -> 0
        x -> 4 - x
      end

    :binary.copy(<<0>>, y)
  end
end
