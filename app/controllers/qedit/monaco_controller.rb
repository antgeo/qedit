module Qedit
  class MonacoController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token

    MONACO_ROOT = Qedit::Engine.root.join("vendor", "monaco-editor").freeze

    MIME_TYPES = {
      ".js"   => "application/javascript",
      ".css"  => "text/css",
      ".ttf"  => "font/ttf",
      ".woff" => "font/woff",
      ".woff2" => "font/woff2",
      ".map"  => "application/json",
    }.freeze

    def serve
      relative = params[:path].to_s
      full = MONACO_ROOT.join(relative).expand_path

      unless full.to_s.start_with?(MONACO_ROOT.to_s + "/")
        render plain: "Forbidden", status: :forbidden and return
      end

      unless File.exist?(full) && File.file?(full)
        render plain: "Not found", status: :not_found and return
      end

      ext = File.extname(full)
      content_type = MIME_TYPES[ext] || "application/octet-stream"

      expires_in 1.year, public: true
      send_file full, type: content_type, disposition: :inline
    end
  end
end
