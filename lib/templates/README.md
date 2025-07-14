# Rails Engine Template

This directory contains a Rails template for generating modular engines in a monolithic Rails application.

## Usage

From your Rails application root:

```bash
rails app:template LOCATION=lib/templates/engine.rb
```

## What it does

1. **Creates a mountable Rails engine** using `rails plugin new` with appropriate flags
2. **Cleans up unwanted files** (.github directory, Gemfile, etc.)
3. **Sets up spec helpers** to inherit from the main app's configuration
4. **Configures RuboCop** to inherit from the main app's configuration
5. **Removes isolated routing** (config/routes.rb) since we're building a modular monolith

## File Structure

- `engine.rb` - Main template file (entry point)
- `engine_generator.rb` - Main generator class that orchestrates the process
- `plugin_command.rb` - Builds the `rails plugin new` command
- `file_cleanup.rb` - Handles removal of unwanted generated files
- `spec_helper_setup.rb` - Sets up spec helper files
- `rubocop_setup.rb` - Configures RuboCop inheritance
- `config_cleanup.rb` - Removes config directory and routes.rb

## Architecture

The template is designed for a modular monolithic architecture where:

- Each engine represents a domain/module
- Engines are stored in the `engines/` directory
- Dependencies are managed via gemspec files in each engine
- The main `Gemfile` uses `engine_scanner.rb` to automatically include engine dependencies
- Shared configuration (RuboCop, specs) is inherited from the main app

## Generated Engine Structure

After running the template, you'll get an engine with:

```
engines/your_engine/
├── your_engine.gemspec
├── lib/
│   ├── your_engine.rb
│   ├── your_engine/
│   │   ├── engine.rb
│   │   └── version.rb
│   └── tasks/
├── app/
│   ├── controllers/
│   ├── models/
│   └── views/
├── spec/
│   ├── rails_helper.rb  # Points to main app's helper
│   └── spec_helper.rb   # Points to main app's helper
└── .rubocop.yml         # Inherits from main app
```

## Benefits

- **Consistent setup** across all engines
- **Shared configuration** for testing and linting
- **Clean separation** of concerns
- **Easy dependency management** via gemspec + scanning
- **No isolated namespacing** - suitable for modular monolith
