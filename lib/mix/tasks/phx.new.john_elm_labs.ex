defmodule Mix.Tasks.Phx.New.JohnElmLabs do
  use Mix.Task

  @shortdoc "Creates a new Phoenix project with John Elm Labs customizations"

  @moduledoc """
  Creates a new Phoenix project with custom configurations and files.

  Usage:

      mix phx.new.john_elm_labs project_name [options]

  This task wraps the default `mix phx.new` and adds custom dependencies,
  configurations, and files tailored to John Elm Labs.
  """

  def run(args) do
    Mix.Task.load_all()
    # Ensure the task can be re-run
    Mix.Task.reenable("phx.new.john_elm_labs")

    # Parse arguments
    case args do
      [] ->
        Mix.raise("Please provide a project name, e.g., mix phx.new.john_elm_labs my_app")

      [project_name | phx_args] ->
        # Step 1: Run the default phx.new task
        Mix.Task.run("phx.new", [project_name | phx_args])

        # Step 2: Change directory to the new project
        File.cd!(project_name)

        # Step 3: Apply customizations
        add_custom_dependencies()
        add_styler_plugin()
        create_custom_schema_file(project_name)
        update_config_file(project_name)

        # Step 4: Run commands within the context of the generated project
        # Fetch and compile dependencies
        Mix.shell().cmd("mix deps.get")
        Mix.shell().cmd("mix deps.compile")

        Mix.shell().info("John Elm Labs customizations have been applied.")

        Mix.shell().info("If you'd like to run phx.gen.auth, you can do so with:")
        Mix.shell().info("cd #{project_name} && mix phx.gen.auth Accounts User users --binary-id")
    end
  end

  defp add_custom_dependencies do
    # Read the current mix.exs content
    mix_exs_content = File.read!("mix.exs")

    # Parse the mix.exs file into an Elixir AST
    {:ok, ast} = Code.string_to_quoted(mix_exs_content)

    # Transform the AST to include new dependencies and preferred_cli_env
    new_ast = Macro.postwalk(ast, fn
      {:defp, meta, [{:deps, _, _} = fun_head, [do: deps_body]]} ->
        # Ensure deps_body is a list
        existing_deps = case deps_body do
          {:__block__, _, deps} -> deps
          deps when is_list(deps) -> deps
          dep -> [dep]
        end

        # Build AST nodes for new dependencies using quote
        new_deps_ast = [
          quote do
            {:styler, "~> 1.2", only: [:dev, :test], runtime: false}
          end,
          quote do
            {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
          end,
          quote do
            {:mix_test_watch, "~> 1.0", only: [:test], runtime: false}
          end
        ]

        # Append new dependencies to existing ones
        updated_deps = existing_deps ++ new_deps_ast

        # Return the updated defp deps function
        {:defp, meta, [fun_head, [do: updated_deps]]}

      {:def, meta, [{:project, _, _} = fun_head, [do: project_body]]} ->
        # Handle project function similarly
        existing_project_config = project_body
        preferred_cli_env = Keyword.get(existing_project_config, :preferred_cli_env, [])
        new_preferred_cli_env = Keyword.put(preferred_cli_env, :"test.watch", :test)
        new_project_config = Keyword.put(existing_project_config, :preferred_cli_env, new_preferred_cli_env)
        {:def, meta, [fun_head, [do: new_project_config]]}

      other ->
        other
    end)

    # Convert the AST back to Elixir code
    updated_mix_exs = Macro.to_string(new_ast)

    # Write the updated content back to mix.exs
    File.write!("mix.exs", updated_mix_exs)
  end

  defp add_styler_plugin do
    # Read the current .formatter.exs content
    formatter_content = File.read!(".formatter.exs")

    # Evaluate the formatter configuration
    {formatter_config, _binding} = Code.eval_string(formatter_content)

    # Update the :plugins key
    updated_config =
      Keyword.update(
        formatter_config,
        :plugins,
        [Styler],
        fn existing_plugins -> existing_plugins ++ [Styler] end
      )

    # Convert the updated configuration back to Elixir code
    updated_content = """
    [
    #{formatter_config_to_string(updated_config)}
    ]
    """

    # Write the updated content back to .formatter.exs
    File.write!(".formatter.exs", updated_content)
  end

  defp formatter_config_to_string(config) do
    config
    |> Enum.map(fn {key, value} ->
      "  #{key}: #{inspect(value, pretty: true)}"
    end)
    |> Enum.join(",\n")
  end

  defp create_custom_schema_file(project_name) do
    module_name = Macro.camelize(project_name)

    file_content = """
    defmodule #{module_name}.Schema do
      defmacro __using__(_) do
        quote do
          use Ecto.Schema

          @primary_key {:id, :binary_id, autogenerate: true}
          @foreign_key_type :binary_id
          @timestamps_opts [type: :utc_datetime_usec]
        end
      end
    end
    """

    # Ensure the directory exists
    File.mkdir_p!("lib/#{project_name}")

    # Write the new file
    File.write!("lib/#{project_name}/schema.ex", file_content)
  end

  defp update_config_file(project_name) do
    module_name = Macro.camelize(project_name)
    app_name = project_name

    config_file = "config/config.exs"
    config_content = File.read!(config_file)

    # Replace the existing config block

    # Define the regex pattern to match the existing config block
    # We'll match 'config :my_app,' and any following lines until the next 'config' keyword or empty line
    config_pattern = ~r/^config\s+:#{app_name},\s*\n(?:\s+.*\n)*?(?=^\s*(config|#|$))/m

    # Build the new config block
    new_config = """
    config :#{app_name},
      ecto_repos: [#{module_name}.Repo],
      generators: [timestamp_type: :utc_datetime_usec]

    """

    updated_config_content =
      if Regex.match?(config_pattern, config_content) do
        # Replace the existing block
        Regex.replace(config_pattern, config_content, new_config)
      else
        # If the existing block is not found, we can add the new config at the top
        new_config <> "\n" <> config_content
      end

    # Now, insert the new configurations before the 'import_config' line

    # Define the pattern to find the 'import_config' line
    import_config_pattern = ~r/^import_config.*$/m

    # Build the new repo configs
    new_repo_configs = """
    config :#{app_name}, #{module_name}.Repo,
      migration_primary_key: [type: :binary_id],
      migration_foreign_key: [type: :binary_id],
      migration_timestamps: [type: :utc_datetime_usec]

    """

    # Insert the new repo configs before the import_config line
    updated_config_content = Regex.replace(import_config_pattern, updated_config_content, new_repo_configs <> "\\0", global: false)

    # Write back the updated config file
    File.write!(config_file, updated_config_content)
  end
end
