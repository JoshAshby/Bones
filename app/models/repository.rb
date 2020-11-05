# frozen_string_literal: true

class Repository
  class Decorator < SimpleDelegator
    attr_accessor :username, :repo, :project_name, :description, :project_code

    def namespaced_name
      "#{ username }/#{ __getobj__[:name] }"
    end

    def url
      "/user/#{ username }/repository/#{ __getobj__[:name] }"
    end
  end

  # rubocop:disable Metrics/AbcSize
  def all_by_account_id id
    username = DB[:accounts].where(id: id).get(:username)
    rows = DB[:repositories].where(account_id: id).all

    Bones::UserFossil.new(username).repositories.map do |repo|
      row = rows.find { _1[:name] == repo.filename }

      dec = Decorator.new row

      dec.username = username
      dec.repo = repo

      repo.repository_db do |db|
        dec.project_name = db[:config].where(name: "project-name").get(:value)
        dec.description = db[:config].where(name: "project-description").get(:value)
        dec.project_code = db[:config].where(name: "project-code").get(:value)
      end

      dec
    end
  end
  # rubocop:enable Metrics/AbcSize
end
