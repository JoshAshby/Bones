# frozen_string_literal: true

class Contracts::Repository < Dry::Validation::Contract
  schema do
    required(:name).filled(:string)
    optional(:password).filled(:string)
    optional(:project_name).filled(:string)
    optional(:clone_url).filled(:string)
  end

  rule(:name) do
    next unless values[:name][%r{\A[A-Za-z1-9_-]+\z}].nil?

    key.failure("Can only contain letter, numbers, underscores and dashes")
  end
end
