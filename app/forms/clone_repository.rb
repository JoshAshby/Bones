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
    schema = CloneContract.new.call attributes
    @errors = schema.errors.to_h
    return false unless errors.empty?

    attributes[:password] = Bones::UserFossil.new(username).clone_repository(
      name,
      admin_password: password,
      url: clone_url
    )

    @repository = {
      account_id: account_id,
      name: name,
      cloned_from: clone_url
    }

    # This is a bit of a hack ... ¯\_(ツ)_/¯
    @repository.yield_self { _1[:id] = DB[:repositories].insert _1 }

    true
  end

  class CloneContract < Dry::Validation::Contract
    schema do
      required(:name).filled(:string)
      optional(:password)
      optional(:clone_url)
    end

    rule(:name) do
      next unless values[:name][%r{\A[A-Za-z1-9_-]+\z}].nil?
      key.failure("Invalid name, can only contain letter, numbers, underscores and dashes")
    end
  end
end
