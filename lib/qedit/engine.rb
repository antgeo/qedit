require "rails/engine"

module Qedit
  class Engine < ::Rails::Engine
    isolate_namespace Qedit

    initializer "qedit.assets" do |app|
      app.config.assets.paths << root.join("vendor", "assets", "javascripts") if app.config.respond_to?(:assets)
    end
  end
end
