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

Tilt.register Cell::Erb::Template, "erb"

CONFIG = YAML.safe_load(Tilt["erb"].new("config/#{ ENV['RACK_ENV'] }.yml").render)

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

# require "erubi/capture_end"

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

    Bones.configure do |config|
      config.root = CONFIG.dig("bones", "repository_root")
    end

    Fossil.configure do |config|
      config.fossil_binary = CONFIG.dig("bones", "fossil_binary")
      config.logger = ->(*args) { LOGGER.fossil(*args) }
    end
  end.start
end

LOADER.setup

FORME_INPUTS = {
  default: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md",
  button: "bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
  submit: "ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
  reset: "",
}

Forme.register_transformer(:formatter, :default) do |tag, input|
  tag.opts[:class] ||= FORME_INPUTS.fetch tag.type, FORME_INPUTS[:default]

  puts
  puts "-------------- formatter (#{ tag.type }) ------------"
  puts tag.opts

  Forme::Formatter.new.call tag
end

Forme.register_transformer(:labeler, :default) do |tag, input|
  input.opts[:label_attr] ||= { class: "block text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" }

  puts
  puts "========= labeler (#{ tag.type }) ========="
  puts input.opts
  puts tag.class

  Forme::Labeler::Explicit.new.call tag, input
end

Forme.register_transformer(:wrapper, :default) do |tags, input|
  puts
  puts "-=-=-=-=-=- Wrapper -=-=-=-=-=-"
  puts input.opts
  puts

  a = Forme::Wrapper.new.call(tags, input).flatten
  labels, other = a.partition { |e| e.is_a?(Forme::Tag) && e.type.to_s == "label" }

  if labels.length == 1
    ltd = labels
    rtd = other
  else
    ltd = a
  end

  rtd = input.tag :div, { class: "mt-1 sm:mt-0 sm:col-span-2" }, [rtd]
  input.tag :div, { class: "sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-gray-200 sm:pt-5" }, [ltd, rtd]
end

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
