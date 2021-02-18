defmodule Bakeware.FileTree do
  alias Bakeware.Assembler

  @moduledoc """
  Builds a FileTree header for recreating decompressed files

  Header structure:

  `<<bw_ft_magic, bw_ft_version, header_length, file_tree_items>>`

  where `file_tree_items` is a repeating structure of:

  `<<file_type, size, path_len, relative_path::size(path_len)-unit(8)>>`
  """

  # ?F + ?T
  @bw_ft_magic 154
  @bw_ft_version 1

  def build(%Assembler{} = assembler) do
    find_files(assembler.rel_path, assembler.rel_path)
    |> finalize_header()

    # TODO: Do something with this

    assembler
  end

  def find_files(path, absolute, acc \\ <<>>) do
    for fp <- File.ls!(path), file_or_dir = Path.join(path, fp), into: acc do
      if File.dir?(file_or_dir) do
        acc = acc <> build_stat(file_or_dir, absolute)
        find_files(file_or_dir, absolute, acc)
      else
        build_stat(file_or_dir, absolute)
      end
    end
  end

  def finalize_header(header) do
    len = byte_size(header)
    <<@bw_ft_magic, @bw_ft_version, len, header::binary>>
  end

  defp build_stat(path, absolute) do
    relative = Path.relative_to(path, absolute)
    stat = File.lstat!(path)
    path_len = byte_size(path)
    <<type_val(stat.type), stat.size, path_len, relative::binary>>
  end

  defp type_val(type) do
    case type do
      :device -> 1
      :directory -> 2
      :regular -> 3
      :symlink -> 4
      :other -> 5
      # unknown
      _ -> 0
    end
  end
end
