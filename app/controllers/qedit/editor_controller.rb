module Qedit
  class EditorController < ApplicationController
    def index
      render layout: false
    end

    def files
      tree = build_tree(Rails.root, Rails.root)
      render json: tree
    end

    def show
      path = safe_path(params[:path])
      content = File.read(path)
      render json: { content: content, language: language_for(path.to_s) }
    rescue Errno::ENOENT
      render json: { error: "File not found" }, status: :not_found
    rescue Errno::EACCES
      render json: { error: "Permission denied" }, status: :forbidden
    end

    def update
      path = safe_path(params[:path])
      content = params[:content].to_s
      File.write(path, content)
      render json: { ok: true }
    rescue Errno::EACCES
      render json: { error: "Permission denied" }, status: :forbidden
    end

    private

    def safe_path(param)
      full = Rails.root.join(param.to_s).expand_path
      unless full.to_s.start_with?(Rails.root.to_s + "/") || full.to_s == Rails.root.to_s
        render json: { error: "Forbidden" }, status: :forbidden
        raise ActionController::RoutingError, "Path traversal detected"
      end
      full
    end

    def build_tree(path, root)
      excluded = Qedit.configuration.excluded_paths
      entries = Dir.entries(path).sort.reject { |e| e.start_with?(".") && e != "." && e != ".." }
                    .reject { |e| e == "." || e == ".." }

      entries.filter_map do |entry|
        full_path = path.join(entry)
        relative  = full_path.relative_path_from(root).to_s

        next if excluded.any? { |ex| relative == ex || relative.start_with?("#{ex}/") }

        if full_path.directory?
          { name: entry, path: relative, type: "directory", children: build_tree(full_path, root) }
        else
          { name: entry, path: relative, type: "file" }
        end
      end
    end

    LANGUAGE_MAP = {
      "rb"     => "ruby",
      "js"     => "javascript",
      "ts"     => "typescript",
      "jsx"    => "javascript",
      "tsx"    => "typescript",
      "html"   => "html",
      "erb"    => "html",
      "css"    => "css",
      "scss"   => "scss",
      "sass"   => "scss",
      "json"   => "json",
      "yml"    => "yaml",
      "yaml"   => "yaml",
      "md"     => "markdown",
      "sh"     => "shell",
      "bash"   => "shell",
      "sql"    => "sql",
      "xml"    => "xml",
      "graphql" => "graphql",
      "gql"    => "graphql",
      "py"     => "python",
      "go"     => "go",
      "rs"     => "rust",
      "java"   => "java",
      "kt"     => "kotlin",
      "swift"  => "swift",
      "tf"     => "hcl",
      "toml"   => "ini",
      "lock"   => "yaml",
    }.freeze

    def language_for(path)
      ext = File.extname(path).delete_prefix(".")
      LANGUAGE_MAP[ext] || "plaintext"
    end
  end
end
