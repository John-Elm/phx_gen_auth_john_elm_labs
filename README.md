# mix phx.new.john_elm_labs

`mix phx.new` with better defaults.
This Mix task generates a customized Phoenix project tailored for John Elm Labs, automating the addition of dependencies, configurations, and files essential for productivity and scalability.

Key Changes and Benefits:
	-	Adds Essential Development Dependencies:
	-	Styler - Ensures consistent code formatting and readability across the project.
	-	Credo - Provides static code analysis and enforces Elixir best practices.
	-	`mix_test_watch` - Automates test execution for a faster development feedback loop.
	-	`phx_gen_auth` - Streamlines user authentication setup with best-practice implementations.
	-	Why - These tools enhance code quality, maintainability, and development efficiency.
	-	Customizes mix.exs:
	-	Updates the `:preferred_cli_env` to include test.watch in the :test environment.
	-	Why - Simplifies test-running workflows and ensures the correct environment is applied.
	-	Applies Custom .formatter.exs Configurations:
	-	Adds Styler as a plugin for consistent formatting.
	-	Why - Enforces a shared code style across teams, reducing formatting-related churn in code reviews.

	Generates a Custom Schema Module:
	-	Creates lib/<project_name>/schema.ex with pre-configured macros for:
	-	`:binary_id` primary and foreign keys.
	-	Microsecond precision timestamps `:utc_datetime_usec.`
	-	Why - Encourages a consistent schema design that aligns with modern Elixir conventions.

	Enhances config/config.exs:
	-	Updates global configuration to use `:utc_datetime_usec` for Ecto timestamps.
	-	Adds default migration key types `(:binary_id)` for Ecto Repo configurations.
	-	Why - Improves precision and consistency in timestamps while simplifying migration setups.

	Runs phx.gen.auth with Preconfigured Options:
	-	Adds a complete user authentication system using `phx_gen_auth`.
	-	Why - Saves time by implementing robust authentication with minimal effort, adhering to Phoenix’s best practices.

Benefits of This Task:
This Mix task significantly reduces the manual effort required to set up a new Phoenix project with standard tools and configurations. By enforcing consistency, integrating modern practices, and including productivity-boosting tools, it helps developers focus on building features rather than setting up boilerplate.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phx_john_elm_labs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phx_john_elm_labs, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/phx_john_elm_labs>.

