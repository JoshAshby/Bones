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
    schema = CreateContract.new.call attributes
    @errors = schema.errors.to_h
    return false unless errors.empty?

    attributes[:password] = Bones::UserFossil.new(username).create_repository(
      name,
      admin_password: password,
      project_name: project_name
    )

    @repository = {
      account_id: account_id,
      name: name
    }

    # This is a bit of a hack ... ¯\_(ツ)_/¯
    @repository.yield_self { _1[:id] = DB[:repositories].insert _1 }

    true
  end

  class CreateContract < Dry::Validation::Contract
    schema do
      required(:name).filled(:string)
      optional(:password)
      optional(:project_name)
    end

    rule(:name) do
      next unless values[:name][%r{\A[A-Za-z1-9_-]+\z}].nil?

      key.failure("Can only contain letter, numbers, underscores and dashes")
    end
  end
end
