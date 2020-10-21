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
    command_name "Minitest::Spec"

    enable_coverage :branch
    add_filter "/spec/"
    add_filter "/env.rb"
    add_filter "/lib/formi"

    %w[ Routes Contracts Forms Cli ].each do |key|
      add_group key, "app/#{ key.downcase }"
    end
  end
end

require "minitest"
require "minitest/test"
require "minitest/spec"
require "minitest/autorun"

require_relative "../env"

Zeitwerk::Loader.eager_load_all

# Temp work around for tty-logger's remove_handler not working as expected
# See my bug report here: https://github.com/piotrmurach/tty-logger/issues/14
handlers = LOGGER.instance_variable_get :@ready_handlers
console_handler = handlers.find { _1.is_a? TTY::Logger::Handlers::Console }
LOGGER.remove_handler(console_handler) unless ENV["STDOUT_TEST_LOGS"]
