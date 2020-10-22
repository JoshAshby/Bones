# frozen_string_literal: true

class Contracts::Repository < Dry::Validation::Contract
  schema do
    required(:name).filled(:string)
    optional(:password).value(:string)
    optional(:project_code).value(:string)
    optional(:clone_url).value(:string)
  end

  rule(:name) do
    next unless values[:name][%r{\A[A-Za-z1-9_-]+\z}].nil?

    key.failure("Can only contain letters, numbers, underscores and dashes")
  end
end
