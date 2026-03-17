require "open3"

module Qedit
  class EditorController < ApplicationController
    def index
      stdout, _stderr, status = Open3.capture3("git", "-C", Rails.root.to_s, "branch", "--show-current")
      @git_branch = status.success? ? stdout.strip.presence : nil
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

    def lint
      path    = safe_path(params[:path])
      content = params[:content].to_s
      render json: run_rubocop(path, content)
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

    RUBOCOP_SEVERITY_MAP = {
      "fatal"      => 8,
      "error"      => 8,
      "warning"    => 4,
      "convention" => 2,
      "refactor"   => 1,
    }.freeze

    def run_rubocop(full_path, content)
      relative = full_path.relative_path_from(Rails.root).to_s
      stdout, _stderr, status = Open3.capture3(
        *Qedit.configuration.rubocop_command.split, "--format", "json", "--stdin", relative,
        stdin_data: content,
        chdir: Rails.root.to_s
      )
      return [] if status.exitstatus.to_i >= 2

      offenses = JSON.parse(stdout).dig("files", 0, "offenses") || []
      offenses.map do |o|
        loc = o["location"]
        col = loc["start_column"] || loc["column"]
        {
          line:      loc["line"],
          column:    col,
          endColumn: col + (loc["length"] || 1),
          severity:  RUBOCOP_SEVERITY_MAP.fetch(o["severity"], 2),
          message:   o["message"]
        }
      end
    rescue Errno::ENOENT, JSON::ParserError
      []
    end
  end
end
