# frozen_string_literal: true

require "rodauth/migrations"

Sequel.migration do
  up do
    extension :date_arithmetic

    deadline_opts = proc do |days|
      if database_type == :mysql
        { null: false }
      else
        { null: false, default: Sequel.date_add(Sequel::CURRENT_TIMESTAMP, days: days) }
      end
    end

    create_table(:account_statuses) do
      Integer :id, primary_key: true
      String :name, null: false, unique: true
    end
    from(:account_statuses).import([:id, :name], [[1, "Unverified"], [2, "Verified"], [3, "Closed"]])

    create_table(:accounts) do
      primary_key :id, type: :Bignum
      foreign_key :status_id, :account_statuses, null: false, default: 1

      String :email, null: false
      index :email, unique: true

      String :username, null: false
      index :username, unique: true
    end

    create_table(:account_password_hashes) do
      foreign_key :id, :accounts, primary_key: true, type: :Bignum
      String :password_hash, null: false
    end

    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, primary_key: true, type: :Bignum
      String :key, null: false
      DateTime :deadline, deadline_opts[1]
      DateTime :email_last_sent, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    create_table(:account_remember_keys) do
      foreign_key :id, :accounts, primary_key: true, type: :Bignum
      String :key, null: false
      DateTime :deadline, deadline_opts[14]
    end
  end
end
