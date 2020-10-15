# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "dotenv", require: false

gem "zeitwerk"

gem "rake"
gem "tty-logger"
gem "tty-option"
# gem "tty-prompt"
# gem "tty-config"

gem "roda"
gem "thin"
gem "tilt"

gem "sqlite3"
gem "sequel"

gem "bcrypt"
gem "mail"
gem "rodauth"

# gem "shrine", "~> 3.0"
gem "forme"

# gem "rufus-scheduler"
# gem "localjob"

group :development do
  gem "listen"

  gem "rubocop"

  gem "sequel-annotate"
end

group :test do
  gem "minitest"
  gem "rack-test"
end

group :test, :development do
  gem "break"
end
