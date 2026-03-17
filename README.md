A code editor built into your rails app. Edit the application from the browser.

This ruby gem uses the Monaco editor to create a editor exposed via the rails route.

The editor can view the entire rails application for editing

**Requires** Rails >= 7.1 · Ruby >= 3.0 · Bundles Monaco Editor v0.55.1 (no CDN or extra dependencies)

## Security warning

qedit exposes **full read and write access** to your entire Rails application directory over HTTP. It is intended exclusively for local development.

- Never install qedit in a production or staging environment
- Never run it on a server accessible to untrusted users
- Always restrict it to the `development` group in your Gemfile

The engine enforces this at runtime — all requests return 403 outside the development environment — but the Gemfile restriction is a second line of defence and prevents the gem from being deployed at all.

## Installation

Add qedit to the **development group only** in your `Gemfile`:

```ruby
gem 'qedit', group: :development
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

This produces a `qedit-x.x.x.gem` file in the current directory.

To install it locally:

```bash
gem install qedit-*.gem
```

Or push it to RubyGems:

```bash
gem push qedit-*.gem
```