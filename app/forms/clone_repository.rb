# frozen_string_literal: true

class Forms::CloneRepository < Forms::Base
  forme_namespace "repository"

  attribute :name, Forms::Types::String
  attribute :clone_url, Forms::Types::String
  attribute? :password, Forms::Types::String.optional

  def repository
    @repository ||= DB[:repositories].where(id: id).first
  end

  def save account_id:, username:
    schema = Contracts::Repository.new.call attributes
    @errors = schema.errors.to_h
    return false unless errors.empty?

    password, _repo = Bones::UserFossil.new(username).clone_repository(
      name,
      admin_password: password,
      url: clone_url
    )

    attributes[:password] = password

    @repository = {
      account_id: account_id,
      name: name,
      cloned_from: clone_url
    }

    # This is a bit of a hack ... ¯\_(ツ)_/¯
    @repository.yield_self { _1[:id] = DB[:repositories].insert _1 }

    true
  end
end
