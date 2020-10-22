# frozen_string_literal: true

class Forms::CreateRepository < Forms::Base
  forme_namespace "repository"

  attribute :name, Forms::Types::String
  attribute? :password, Forms::Types::String.optional
  attribute? :project_code, Forms::Types::String.optional

  def repository
    @repository ||= DB[:repositories].where(id: id).first
  end

  def save account_id:, username:
    schema = Contracts::Repository.new.call attributes
    @errors = schema.errors.to_h
    return false unless errors.empty?

    attributes[:password] = Bones::UserFossil.new(username).create_repository(
      name,
      admin_password: password,
      project_code: project_code
    )

    @repository = {
      account_id: account_id,
      name: name
    }

    # This is a bit of a hack ... ¯\_(ツ)_/¯
    @repository.yield_self { _1[:id] = DB[:repositories].insert _1 }

    true
  end
end
