# frozen_string_literal: true
require "open3"

class FossilRepo
  def self.root
    @root ||= Pathname.new ENV["REPO_ROOT"]
  end

  attr_reader :username, :user_root, :repo_root

  def initialize username
    @username = username
    @user_root = FossilRepo.root.join username
    @repo_root = @user_root.join "data"

    ensure_dirs!
    ensure_cgi_script!
  end

  def create_repository repo
    if repository_file(repo).exist?
      LOGGER.fossil "Attempted to create an existing repo #{ repository_file(repo) }"
      throw "Attempted to create an existing repo #{ repository_file(repo) }"
    end

    run_fossil_command "new", "--admin-user", @username, repository_file(repo).to_s
  end

  def repository_file repo
    @repo_root.join "#{ repo }.fossil"
  end

  def run_fossil_command *args
    log, status = Open3.capture2e(fossil_binary, *args)
    LOGGER.fossil "Ran fossil command with args [#{ args.join ', ' }]", status: status
    LOGGER.fossil log
    status
  end

  protected

  def fossil_binary
    ENV["FOSSIL_BINARY"]
  end

  def ensure_dirs!
    @repo_root.mkpath unless @repo_root.exist?
  end

  def ensure_cgi_script!
    script = @user_root.join("repo")

    return if script.exist?

    script.open File::CREAT | File::WRONLY, 0o555 do |file|
      file.write <<~CGI
        #!#{ fossil_binary }
        directory: ./data/
        notfound: /404
      CGI
    end
  end
end
