# frozen_string_literal: true

$:.unshift(::File.expand_path('./',  __FILE__))
# require ::File.expand_path('../rodauth_demo',  __FILE__)

require "dotenv/load"

ENV["RACK_ENV"] ||= "development"

require "bundler"
Bundler.require :default, ENV["RACK_ENV"].to_sym

LOGGER = TTY::Logger.new do |config|
  config.metadata = %i[date time]

  config.level = ENV["RACK_ENV"] == "development" ? :debug : :warn

  config.types = {
    database: { level: :debug },
    request: { level: :info },
    fossil: { level: :debug },
  }

  config.handlers = [
    [:console, {
      styles: {
        database: {
          label: "db",
          color: :magenta,
          levelpad: 0
        },
        request: {
          label: "request",
          levelpad: 0
        },
        fossil: {
          label: "FOSSIL",
          levelpad: 0
        }
      }
    }]
  ]
end

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses. DATABASE_URL may contain passwords.
DB = Sequel.connect ENV.delete("DATABASE_URL"), logger: LOGGER
DB.sql_log_level = :database

DB.extension :date_arithmetic

Sequel.extension :core_refinements

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :forme
Sequel::Model.plugin :forme_set

# Sequel::Model.cache_associations = false if ENV["RACK_ENV"] == "development"

# Sequel::Model.plugin :auto_validations
# Sequel::Model.plugin :prepared_statements
# Sequel::Model.plugin :subclasses unless ENV["RACK_ENV"] == "development"
# Sequel::Model.plugin :dirty
# Sequel::Model.db.extension(:pagination)

# Sequel::Model.raise_on_save_failure = false

# require "shrine/storage/file_system"

# Shrine.storages = {
  # cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  # store: Shrine::Storage::FileSystem.new("public", prefix: "uploads")
# }

# Shrine.plugin :sequel
# Shrine.plugin :rack_file
# Shrine.plugin :rack_response
# Shrine.plugin :cached_attachment_data
# Shrine.plugin :validation
# Shrine.plugin :validation_helpers

Thread.abort_on_exception = true
trap("INT") { exit }
trap("TERM") { exit }

FOLDERS = %w[lib app app/models].freeze

LOADER = Zeitwerk::Loader.new
FOLDERS.each(&LOADER.method(:push_dir))

if ENV["RACK_ENV"] == "development"
  # LOADER.log!
  LOADER.enable_reloading

  Listen.to(*FOLDERS, wait_for_delay: 1) do
    LOADER.reload
  end.start
end

LOADER.setup
