# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:repositories) do
      primary_key :id

      foreign_key :account_id, :accounts
      String :name

      String :cloned_from
    end
  end
end
