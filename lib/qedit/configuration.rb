module Qedit
  class Configuration
    EXCLUDED_PATHS = %w[
      .git
      tmp
      log
      node_modules
      .bundle
      coverage
      vendor/bundle
    ].freeze

    attr_accessor :excluded_paths, :rubocop_command

    def initialize
      @excluded_paths  = EXCLUDED_PATHS.dup
      @rubocop_command = "rubocop"
    end
  end
end
