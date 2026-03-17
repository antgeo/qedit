require_relative "lib/qedit/version"

Gem::Specification.new do |spec|
  spec.name        = "qedit"
  spec.version     = Qedit::VERSION
  spec.authors     = ["Anthony Georges"]
  spec.email       = ["anthony@anthonygeorges.com"]
  spec.homepage    = "https://github.com/antgeo/qedit"
  spec.summary     = "A code editor built into your Rails app — edit the application from the browser."
  spec.description = "Embeds Monaco Editor into a Rails application via a mountable engine, allowing you to browse and edit application files directly from the browser. Development environment only."
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri"          => "https://github.com/antgeo/qedit",
    "source_code_uri"       => "https://github.com/antgeo/qedit",
    "bug_tracker_uri"       => "https://github.com/antgeo/qedit/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir[
    "lib/**/*",
    "app/**/*",
    "config/**/*",
    "vendor/**/*",
    "LICENSE",
    "README.md"
  ]

  spec.add_dependency "railties", ">= 7.1"
  spec.add_dependency "actionpack", ">= 7.1"
end
