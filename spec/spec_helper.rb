# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "capybara/dsl"
require "rack/test"

require "minitest"
require "minitest/test"
require "minitest/spec"
require "minitest/autorun"

require_relative "../env"

LOGGER.remove_handler(:console)
