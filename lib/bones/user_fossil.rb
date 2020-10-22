# frozen_string_literal: true

class Bones::UserFossil
  CGI_SCRIPT_NAME = "repository"

  attr_reader :username, :user_root, :repo_root

  def initialize username
    @username = username

    @user_root = Bones.root.join username
    @repo_root = @user_root.join "data"
  end

  def ensure_fs!
    ensure_repo_dirs
    ensure_cgi_script
  end

  def repository_names
    @repo_root.children(false)
      .map(&:basename)
      .map(&:to_s)
  end

  # Creates a new repository by the given name, sets the admin password or
  # generates one and updates a few settings including the project-code if
  # included.
  #
  # Note: changing the password has to happen after the project-code is
  # changed, as it seems fossil uses the project-code to salt it's password
  # hashes to some extent
  def create_repository name, admin_password:, project_code:
    repo = repository name

    repo.create_repository username: username

    repo.repository_db do |db|
      # little bit of security, prevents someone on the server from accessing
      # the web ui without credentials
      db[:config].where(name: "localauth").update(value: 1)

      # Set the project name, on new repos this doesn't seem to exist so lets
      # insert it and I'll worry about problems later. This could be expanded
      # to include other data too in the future such as the description and
      # logo too perhaps?
      db[:config].insert(name: "project-name", value: name, mtime: Time.now)

      # Change the project code if provided. This allows you to push an
      # existing repository up.
      db[:config].where(name: "project-code").update(value: project_code) if project_code
    end

    repo.change_password username: username, password: admin_password
  end

  def clone_repository name, url:, admin_password:
    repo = repository name

    repo.clone_repository username: username, url: url

    repo.repository_db do |db|
      # little bit of security, prevents someone on the server from accessing
      # the web ui without credentials
      db[:config].where(name: "localauth").update(value: 1)
    end

    repo.change_password username: username, password: admin_password
  end

  def repository repo
    repo = "#{ repo }.fossil" unless repo.end_with? ".fossil"
    Fossil::Repo.new @repo_root.join(repo)
  end

  def repositories
    repository_names.map(&method(:repository))
  end

  def remove_cgi_script!
    @user_root.join(CGI_SCRIPT_NAME).delete
  end

  protected

  def ensure_repo_dirs
    @repo_root.mkpath unless @repo_root.exist?
  end

  def ensure_cgi_script
    script = @user_root.join(CGI_SCRIPT_NAME)

    return if script.exist?

    script.open File::CREAT | File::WRONLY, 0o555 do |file|
      file.write <<~CGI
        #!#{ Fossil.fossil_binary }
        directory: ./data/
        notfound: /404
      CGI
    end
  end
end
