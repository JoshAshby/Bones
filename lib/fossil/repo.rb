# frozen_string_literal: true

require "open3"

class Fossil::Repo
  attr_reader :repo, :repository_file

  def initialize repository_file:
    @repository_file = repository_file

    @repo = repository_file.basename.sub_ext("").to_s
  end

  def create_repository! username:
    if repository_file.exist?
      LOGGER.fossil "Attempted to create an existing repo #{ repository_file }"
      fail "Attempted to create an existing repo #{ self }"
    end

    status = run_fossil_command "new", "--admin-user", username, repository_file.to_s
    fail "abnormal status creating new fossil #{ self } - #{ status.exitstatus }" unless status.success?

    nil
  end

  def create_user username:, contact_info:, password:
    password ||= SecureRandom.hex(20)

    status = run_fossil_command "user", "new", username, contact_info, password, "--repository", repository_file.to_s
    fail "abnormal status creating a new user in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    status = run_fossil_command "user", "capabilities", username, "s", "--repository", repository_file.to_s
    fail "new user doesn't have superadmin capabilities in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    password
  end

  def change_password username:, password: nil
    password ||= SecureRandom.hex(20)

    status = run_fossil_command "user", "password", username, password, "--repository", repository_file.to_s
    fail "abnormal status creating a new user in fossil #{ self } - #{ status.exitstatus }" unless status.success?

    password
  end

  def run_fossil_command *args
    log, status = Open3.capture2e(Fossil.fossil_binary, *args)
    LOGGER.fossil "Ran fossil command with args [#{ args.join ', ' }]", status: status
    LOGGER.fossil log
    status
  end

  def repository_db
    db = Sequel.connect "sqlite://#{ repository_file }", logger: LOGGER

    if block_given?
      yield db

      db.disconnect
    else
      db
    end
  end
end
