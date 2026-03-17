A code editor built into your rails app. Edit the application from the browser.

This ruby gem uses the Monaco editor to create a editor exposed via the rails route.

The editor can view the entire rails application for editing

Supports Rails 7.1 or greater and Ruby 3.0

The latest version of Monaco is included

## Installation

Add this line to your Rails application's `Gemfile`:

```ruby
gem 'qedit'
```

Then run:

```bash
bundle install
```

Mount the engine in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Qedit::Engine, at: '/qedit'
end
```

The editor will be available at `http://localhost:3000/qedit`.

## Configuration

Create an initializer at `config/initializers/qedit.rb`:

```ruby
Qedit.configure do |config|
  # Paths to exclude from the file browser (default shown below)
  config.excluded_paths = %w[.git tmp log node_modules .bundle coverage vendor/bundle]

  # RuboCop command used for inline linting (default: "rubocop")
  # Use "bundle exec rubocop" if rubocop is managed via Bundler
  config.rubocop_command = "bundle exec rubocop"
end
```

Inline RuboCop diagnostics appear automatically for Ruby files — red/yellow squiggles with hover messages. No extra setup is required as long as RuboCop is available via the configured command. If it isn't installed, linting is silently skipped.

## Building the gem

Ensure you have Ruby installed, then run:

```bash
gem build qedit.gemspec
```

This produces a `qedit-0.1.0.gem` file in the current directory.

To install it locally:

```bash
gem install qedit-0.1.0.gem
```

Or push it to RubyGems:

```bash
gem push qedit-0.1.0.gem
```