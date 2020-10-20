# frozen_string_literal: true

module Cli::Commands
  extend Dry::CLI::Registry

  register "user create", Cli::User::Create
  register "user delete", Cli::User::Delete
  register "user edit", Cli::User::Edit
end
