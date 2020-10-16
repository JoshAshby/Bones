# frozen_string_literal: true

class Bones::UserFossil
  attr_reader :username, :user_root, :repo_root

  def initialize username:
    @username = username

    @user_root = Bones.root.join username
    @repo_root = @user_root.join "data"

    ensure_dirs!
    ensure_cgi_script!
  end

  protected

  def ensure_dirs!
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
