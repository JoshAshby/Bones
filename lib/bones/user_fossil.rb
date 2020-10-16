# frozen_string_literal: true

class Bones::UserFossil
  attr_reader :username, :user_root, :repo_root

  def initialize username
    @username = username

    @user_root = Bones.root.join username
    @repo_root = @user_root.join "data"
  end

  def ensure_fs!
    ensure_repo_dirs!
    ensure_cgi_script!
  end

  def repositories
    @repo_root.children(false)
      .map(&:basename)
      .map(&:to_s)
  end

  def repository repo
    repo = "#{repo}.fossil" unless repo.end_with? ".fossil"
    Fossil::Repo.new @repo_root.join(repo)
  end

  protected

  def ensure_repo_dirs!
    @repo_root.mkpath unless @repo_root.exist?
  end

  def ensure_cgi_script!
    script = @user_root.join("repo")

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
