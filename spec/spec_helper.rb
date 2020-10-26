# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

unless ENV["NO_GEM_WARNINGS"] == "false"
  require "warning"

  # Ignore all gem related warnings for now
  Gem.path.each { |path| Warning.ignore(%r{}, path) }
  Warning.dedup if Warning.respond_to?(:dedup)
end

unless ENV["COVERAGE"] == "false"
  require "simplecov"
  SimpleCov.start do
    command_name "rspec"

    enable_coverage :branch
    add_filter "/spec/"
    add_filter "/env.rb"
    add_filter "/lib/formi"

    add_filter %r{/lib/(.*)_logger.rb}

    %w[ Routes Contracts Forms Cli ].each do |key|
      add_group key, "app/#{ key.downcase }"
    end
  end
end

require_relative "../env"
Zeitwerk::Loader.eager_load_all

Dir["#{ File.dirname(__FILE__) }/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.filter_run_when_matching :focus

  config.around do |example|
    DB.transaction(rollback: :always, savepoint: true) do
      example.run
    end

    FileUtils.remove_dir "./tmp" if Dir["./tmp"].any?
  end
end

Sequel.extension :migration
Sequel::Migrator.apply DB, "migrations"
