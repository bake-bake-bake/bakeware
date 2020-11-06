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

    File.close(fd)

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
    relative = Path.relative_to(path, release_path) <> <<0>>

    IO.write(fd, build_header(stats, relative))
    IO.write(fd, relative)

    if stats.type != :directory do
      File.open(path, [:read], &append_file(&1, fd))
    end
  end

  defp append_file(fd, cpio_fd) do
    Enum.each(IO.stream(fd, :line), &IO.write(cpio_fd, &1))
  end

  defp build_header(stats, relative) do
    namesize = byte_size(relative)

    [
      @cpio_magic,
      zero(),
      pad_hex(stats.mode),
      zero(),
      zero(),
      zero(),
      zero(),
      pad_hex(stats.size),
      zero(),
      zero(),
      zero(),
      zero(),
      pad_hex(namesize),
      zero()
    ]
    |> Enum.join()
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
end
