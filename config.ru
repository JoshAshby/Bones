# frozen_string_literal: true

require_relative "env"

if ENV["RACK_ENV"] == "production"
  Zeitwerk::Loader.eager_load_all
  DB.freeze
  run Routes::Root.freeze.app
else
  run ->(env) { Routes::Root.call env }
end
