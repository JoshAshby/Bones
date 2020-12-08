# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "dotenv", require: false

gem "zeitwerk"

gem "rake"
gem "tty-logger"

gem "thin"

gem "roda"
gem "rodauth"

gem "tilt"
gem "nokogiri"
gem "forme"

gem "cells", github: "trailblazer/cells"
gem "cells-erb", github: "trailblazer/cells-erb"

gem "sqlite3"
gem "sequel"

# gem "shrine", "~> 3.0"

gem "bcrypt"
gem "mail"

gem "dry-struct"
gem "dry-types"
gem "dry-validation"
gem "dry-cli"

# gem "rufus-scheduler"
# gem "localjob"

group :development do
  gem "listen"

  gem "rubocop", require: false
  gem "rubocop-rspec", require: false

  # gem "sequel-annotate"
end

group :test do
  gem "rspec"

  gem "simplecov", require: false
  gem "warning", require: false

  gem "rack-test"
  gem "capybara"
end

group :test, :development do
  gem "break"
end
