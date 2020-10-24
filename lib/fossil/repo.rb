# frozen_string_literal: true

require "open3"

# Common utility class for performing actions on a fossil repository.
class Fossil::Repo
  class << self
    # Creates a new fossil repository at the initialized file location with
    # an admin user of the given username.
    #
    # Returns a new instance of Repo
    #
    # Fails with a rdoc-ref:Fossil::ExistingRepositoryError if there is already
    # a repository at the location.
    #
    # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
    # non-zero status.
    def create repository_path, username:
      if repository_path.exist?
        Fossil.log "Attempted to create an existing repo #{ repository_path }"
        fail Fossil::ExistingRepositoryError, "Attempted to create an existing repo #{ self }"
      end

      Fossil.run_fossil_command "new", "--admin-user", username, repository_path.to_s

      new repository_path
    end

    # Clone a remote repository to the initialized file location with
    # an admin user of the given username.
    #
    # Returns a new instance of Repo
    #
    # Fails with a rdoc-ref:Fossil::ExistingRepositoryError if there is already
    # a repository at the location.
    #
    # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
    # non-zero status.
    def clone repository_path, url:, username:
      if repository_path.exist?
        Fossil.log "Attempted to clone an existing repo #{ repository_path }"
        fail Fossil::ExistingRepositoryError, "Attempted to clone an existing repo #{ self }"
      end

      Fossil.run_fossil_command "clone", "--admin-user", username, url, repository_path.to_s

      new repository_path
    end
  end

  attr_reader :filename, :path

  def initialize path
    @path = path
    @filename = path.basename.sub_ext("").to_s
  end

  # Removes the Fossil repository file.
  def delete!
    FileUtils.remove_file path.to_s
  end

  # Creates a new user and adds the 's' superuser capability to the new user.
  #
  # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
  # non-zero status.
  #
  # TODO: This could probably be broken up into create_user and
  # add/remove_user_capability
  #
  # See {Fossil Capability 's'}(https://fossil-scm.org/home/doc/trunk/www/caps/admin-v-setup.md)
  def create_setup_user username:, contact_info:, password:
    fail ArgumentError, "Password cannot be empty" if password.empty?

    Fossil.run_fossil_command "user", "new", username, contact_info, password, "--repository", path.to_s
    Fossil.run_fossil_command "user", "capabilities", username, "s", "--repository", path.to_s
  end

  # Changes an existing users password.
  #
  # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
  # non-zero status.
  def change_password username:, password:
    fail ArgumentError, "Password cannot be empty" if password.empty?

    Fossil.run_fossil_command "user", "password", username, password, "--repository", path.to_s
  end

  # Connects to the Fossil repository as a Sqlite DB.
  #
  # Yields the connection and automatically closes it at the end
  def repository_db &block
    Sequel.connect "sqlite://#{ path }", logger: LOGGER, &block
  end
end
