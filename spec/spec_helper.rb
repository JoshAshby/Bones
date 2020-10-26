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

    %w[ Routes Contracts Forms Cli ].each do |key|
      add_group key, "app/#{ key.downcase }"
    end
  end
end

require_relative "../env"

Zeitwerk::Loader.eager_load_all

# Temp work around for tty-logger's remove_handler not working as expected
# See my bug report here: https://github.com/piotrmurach/tty-logger/issues/14
handlers = LOGGER.instance_variable_get :@ready_handlers
console_handler = handlers.find { _1.is_a? TTY::Logger::Handlers::Console }
LOGGER.remove_handler(console_handler) unless ENV["STDOUT_TEST_LOGS"]

# Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

require "rack/test"
require "capybara/dsl"

Capybara.app = Routes::Root.app

RSpec.configure do |config|
  config.mock_with :rspec

  config.filter_run_when_matching :focus

  config.around :each do |example|
    DB.transaction(rollback: :always, savepoint: true) do
      example.run
    end

    FileUtils.remove_dir "./tmp" if Dir["./tmp"].any?
  end

  config.after type: :feature do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  config.include Rack::Test::Methods, type: :feature
  config.include Capybara::DSL, type: :feature

  config.alias_example_group_to :feature, type: :feature
  config.alias_example_to :scenario

  def app
    Rack::Lint.new Routes::Root.app
  end

  def create_user email: "test@example.com", username: "testing", password: "testing", status_id: 2
    account_id = DB[:accounts].insert(
      email: email,
      username: username,
      status_id: status_id
    )

    DB[:account_password_hashes].insert(
      id: account_id,
      password_hash: BCrypt::Password.create(password).to_s
    )

    Bones::UserFossil.new(username).ensure_fs!
  end

  def login_user email: "test@example.com", password: "testing"
    visit "/"
    fill_in "login", with: email
    fill_in "password", with: password
    click_on "Log In"
  end
end

Sequel.extension :migration
Sequel::Migrator.apply DB, "migrations"
