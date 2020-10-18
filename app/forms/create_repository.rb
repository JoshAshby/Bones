# frozen_string_literal: true

class Forms::CreateRepository < Forms::Base
  forme_namespace "repository"

  attribute :name, Forms::Types::String
  attribute? :password, Forms::Types::String.optional
  attribute? :project_name, Forms::Types::String.optional

  def repository
    @repository ||= DB[:repositories].where(id: id).first
  end

  def save account_id:, username:
    self.password = Bones::UserFossil.new(username).clone_repository(
      name,
      admin_password: password,
      project_name: project_name
    )

    # This is a bit of a hack ... ¯\_(ツ)_/¯
    @repository = {
      account_id: account_id,
      name: name
    }.yield_self { _1[:id] = DB[:repositories].insert _1 }

    true
  end
end
