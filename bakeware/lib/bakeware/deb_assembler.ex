defmodule Bakeware.DebAssembler do
  @moduledoc false

  @doc false
  def assemble(%Mix.Release{} = release) do
    exe = "_build/prod/rel/bakeware/simple_app"
    bake_path = Path.dirname(release.path) |> Path.join("bakeware")
    deb_build_path = Path.join(bake_path, "deb")
    debian_path = Path.join(deb_build_path, "DEBIAN")
    bin_path = Path.join(debian_path, "usr/bin")
    control_path = Path.join(debian_path, "control")
    _ = File.mkdir_p!(debian_path)
    _ = File.mkdir_p!(bin_path)

    control = assemble_control(release, Mix.Project.config())
    File.write!(control_path, control)
    File.cp!(exe, Path.join(bin_path, "simple_app"))
    output_debfile = Path.join(bake_path, ["simple_app.deb"])

    IO.puts("""
    #{IO.ANSI.green()}* assembling#{IO.ANSI.default_color()} bakeware deb package for #{
      release.name
    }
    """)

    {_, 0} = System.cmd("dpkg-deb", ["--build", deb_build_path, output_debfile])

    IO.puts("Bakeware successfully assembled deb executable at #{output_debfile}")

    release
  end

  def assemble_control(release, config) do
    deb_config = config[:bakeware][:deb]
    exe = "_build/prod/rel/bakeware/simple_app"
    installed_size = byte_size(File.read!(exe))
    debian_pkg_name = String.replace(to_string(release.name), "_", "-")

    """
    Package: #{debian_pkg_name}
    Version: #{release.version}
    Section: #{deb_config[:section] || "custom"}
    Priority: #{deb_config[:priority] || "optional"}
    Architecture: #{deb_config[:architecture] || "amd64"}
    Essential: no
    Installed-Size: #{installed_size}
    Maintainer: #{deb_config[:maintainer] || "nobody"}
    Description: #{config[:description] || "Bakeware OTP app"}

    """
  end
end
