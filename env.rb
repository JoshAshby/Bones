# frozen_string_literal: true

$LOAD_PATH.unshift(::File.expand_path(__FILE__))

require "dotenv/load"

ENV["RACK_ENV"] ||= "development"

require "bundler"
Bundler.require :default, ENV["RACK_ENV"].to_sym

logfile = Pathname.new("logs/#{ ENV['RACK_ENV'] }.log")
logfile.parent.mkpath

LOGGER = TTY::Logger.new do |config|
  config.metadata = %i[date time]

  config.level = ENV["RACK_ENV"] == "production" ? :warn : :debug

  config.types = {
    database: { level: :debug },
    request: { level: :info },
    fossil: { level: :debug },
    mail: { level: :debug }
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
        },
        mail: {
          label: "mail",
          levelpad: 0
        }
      }
    }],
    [:stream, {
      output: logfile.open("a+")
    }]
  ]
end

CONFIG = YAML.safe_load(Tilt::ErubiTemplate.new("config/#{ ENV['RACK_ENV'] }.yml").render)

# Delete DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses. DATABASE_URL may contain passwords.
DB = Sequel.connect CONFIG.dig("database", "url"), logger: LOGGER
DB.sql_log_level = :database

DB.extension :date_arithmetic

Sequel.extension :core_refinements

# Sequel::Model.plugin :timestamps, update_on_create: true
# Sequel::Model.plugin :forme
# Sequel::Model.plugin :forme_set

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

require "erubi/capture_end"

Thread.abort_on_exception = true
trap("INT") { exit }
trap("TERM") { exit }

FOLDERS = %w[lib app app/models].freeze

LOADER = Zeitwerk::Loader.new
FOLDERS.each(&LOADER.method(:push_dir))

if ENV["RACK_ENV"] == "development"
  LOADER.log! if ENV["DEBUG_LOADER"]
  LOADER.enable_reloading

  Listen.to(*FOLDERS, wait_for_delay: 1) do
    LOADER.reload
  end.start
end

LOADER.setup

Formi.register_to_forme
Forme.default_config = :formi

Mail.defaults do
  if CONFIG.dig("mail", "delivery_method") == "logger"
    delivery_method ::DeliveryLogger
  else
    config = CONFIG["mail"]
    delivery_method(config["delivery_method"].to_sym, **config.fetch("delivery_options", {}).transform_keys(&:to_sym))
  end
end

Bones.configure do |config|
  config.root = CONFIG.dig("bones", "repository_root")
end

Fossil.configure do |config|
  config.fossil_binary = CONFIG.dig("bones", "fossil_binary")
  config.logger = ->(*args) { LOGGER.fossil(*args) }
end
