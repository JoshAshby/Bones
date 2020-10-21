# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

if ENV["COVERAGE"]
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
LOGGER.remove_handler(:console)
