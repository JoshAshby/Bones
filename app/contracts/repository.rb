class Contracts::Repository < Dry::Validation::Contract
    schema do
      required(:name).filled(:string)
      optional(:password)
      optional(:project_name)
      optional(:clone_url)
    end

    rule(:name) do
      next unless values[:name][%r{\A[A-Za-z1-9_-]+\z}].nil?

      key.failure("Can only contain letter, numbers, underscores and dashes")
    end
end
