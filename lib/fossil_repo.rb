# frozen_string_literal: true

require "open3"

class FossilRepo
  def self.root
    @root ||= Pathname.new ENV["REPO_ROOT"]
  end

  attr_reader :username, :repo, :user_root, :repo_root, :repository_file

  def initialize username:, repo:
    @username = username
    @repo = repo

    @user_root = FossilRepo.root.join username
    @repo_root = @user_root.join "data"

    @repository_file = @repo_root.join "#{ repo }.fossil"

    ensure_dirs!
    ensure_cgi_script!
  end

  def create_repository!
    if repository_file.exist?
      LOGGER.fossil "Attempted to create an existing repo #{ repository_file }"
      fail "Attempted to create an existing repo #{ self }"
    end

    status = run_fossil_command "new", "--admin-user", username, repository_file.to_s
    fail "abnormal status creating new fossil #{ self } - #{ status.exitstatus }" unless status.success?

    nil
  end

  def create_user user
    password = SecureRandom.hex(20)

    status = run_fossil_command "user", "new", user, "Bones User", password, "--repository", repository_file.to_s
    fail "abnormal status creating a new user in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    status = run_fossil_command "user", "capabilities", user, "s", "--repository", repository_file.to_s
    fail "new user doesn't have superadmin capabilities in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    password
  end

  def change_password user, password=nil
    password ||= SecureRandom.hex(20)

    status = run_fossil_command "user", "password", user, password, "--repository", repository_file.to_s
    fail "abnormal status creating a new user in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    password
  end

  def run_fossil_command *args
    log, status = Open3.capture2e(fossil_binary, *args)
    LOGGER.fossil "Ran fossil command with args [#{ args.join ', ' }]", status: status
    LOGGER.fossil log
    status
  end

  def repository_db
    db = Sequel.connect "sqlite://#{ repository_file }", logger: LOGGER

    yield db

    db.disconnect
  end

  def to_s
    "<FossilRepo #{ username }/#{ repo }>"
  end

  protected

  def fossil_binary
    ENV["FOSSIL_BINARY"]
  end

  # TODO: Move this out to a user helper?
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
