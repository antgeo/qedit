require "qedit/version"
require "qedit/configuration"
require "qedit/engine"

module Qedit
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
