defmodule BakewareTest do
  use ExUnit.Case, async: true
  doctest Bakeware

  @rel_test_path Path.expand(Path.join([__DIR__, "fixtures", "rel_test"]))
  @rel_test_binary Path.expand(
                     Path.join([
                       __DIR__,
                       "fixtures",
                       "rel_test",
                       "_build",
                       "prod",
                       "rel",
                       "bakeware",
                       "rel_test"
                     ])
                   )

  setup_all do
    build(@rel_test_path)
  end

  defp build(path) do
    options = [cd: path, env: [{"MIX_ENV", "prod"}]]

    # Start fresh
    ["_build", "mix.lock", "deps"]
    |> Enum.map(&Path.join(path, &1))
    |> Enum.each(&File.rm_rf!/1)

    {_, 0} = System.cmd("mix", ["deps.get"], options)

    {_, 0} = System.cmd("mix", ["release"], options)

    :ok
  end

  defp fix_tmp_dir(tmp_dir) when is_binary(tmp_dir) do
    tmp_dir
  end

  defp fix_tmp_dir(_tmp_dir) do
    # Elixir 1.10 and earlier
    path = Path.join(["tmp", "BakewareTest", Integer.to_string(:rand.uniform(10000))])
    File.mkdir_p!(path)
    path
  end

  test "creates executable" do
    assert File.exists?(@rel_test_binary)
  end

  @tag :tmp_dir
  test "install creates expected directories", %{tmp_dir: tmp_dir} do
    tmp_dir = fix_tmp_dir(tmp_dir)

    {_, 0} =
      System.cmd(@rel_test_binary, ["--bw-install"],
        env: [{"BAKEWARE_CACHE", Path.absname(tmp_dir)}]
      )

    cache_files = File.ls!(tmp_dir)

    assert ".index" in cache_files
    assert ".tmp" in cache_files

    index_files = File.ls!(Path.join(tmp_dir, ".index"))
    tmp_files = File.ls!(Path.join(tmp_dir, ".tmp"))

    # Check that no temporary files were left behind
    assert tmp_files == []

    # Check that index was created properly
    assert length(index_files) == 1
    [index_file] = index_files
    src_path = File.read!(Path.join([tmp_dir, ".index", index_file])) |> String.trim()
    assert src_path == @rel_test_binary

    # Check the that the expansion looks reasonable
    dirs = cache_files -- [".index", ".tmp"]
    assert length(dirs) == 1
    [expansion_path] = dirs

    expansion_files = File.ls!(Path.join(tmp_dir, expansion_path))
    assert "lib" in expansion_files
    assert "bin" in expansion_files
    assert "releases" in expansion_files
    assert "start" in expansion_files
  end

  @tag :tmp_dir
  test "run bakeware executable", %{tmp_dir: tmp_dir} do
    tmp_dir = fix_tmp_dir(tmp_dir)

    {result, 0} =
      System.cmd(@rel_test_binary, [], env: [{"BAKEWARE_CACHE", Path.absname(tmp_dir)}])

    assert result == "Hello, OTP Application!\n"

    # Run from cache
    {result, 0} =
      System.cmd(@rel_test_binary, [], env: [{"BAKEWARE_CACHE", Path.absname(tmp_dir)}])

    assert result == "Hello, OTP Application!\n"
  end

  @tag :tmp_dir
  test "run bakeware executable simultaneously", %{tmp_dir: tmp_dir} do
    tmp_dir = fix_tmp_dir(tmp_dir)

    # Test out launching the executable multiple times simultaneously.
    # Everything should run ok, but internally, the extractors will
    # step on each other and resolve the situation.
    tasks =
      for _ <- 1..4 do
        Task.async(fn ->
          System.cmd(@rel_test_binary, [], env: [{"BAKEWARE_CACHE", Path.absname(tmp_dir)}])
        end)
      end

    results =
      for task <- tasks do
        Task.await(task, 30000)
      end

    for result <- results do
      assert result == {"Hello, OTP Application!\n", 0}
    end

    # Check that the tmp directory got cleaned up
    tmp_files = File.ls!(Path.join(tmp_dir, ".tmp"))
    assert tmp_files == []

    # Only one index
    index_files = File.ls!(Path.join(tmp_dir, ".index"))
    assert length(index_files) == 1
  end

  test "get info from a bakeware executable" do
    {result, 0} =
      System.cmd(@rel_test_binary, ["--bw-info"], env: [{"BAKEWARE_CACHE", "/nowhere"}])

    assert result =~ ~r/Trailer version: 1/
  end

  @tag :tmp_dir
  test "changing the start command", %{tmp_dir: tmp_dir} do
    command_test_path = Path.expand(Path.join([__DIR__, "fixtures", "command_test"]))

    command_test_binary =
      Path.expand(
        Path.join([command_test_path, "_build", "prod", "rel", "bakeware", "command_test"])
      )

    build(command_test_path)

    tmp_dir = fix_tmp_dir(tmp_dir)

    {result, 0} =
      System.cmd(command_test_binary, [], env: [{"BAKEWARE_CACHE", Path.absname(tmp_dir)}])

    # See the command test's mix.exs file to see that it runs "version" by default
    assert result == "command_test 0.1.0\n"
  end
end
