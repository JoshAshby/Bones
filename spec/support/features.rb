# frozen_string_literal: true

require "rack/test"
require "capybara/dsl"

Capybara.app = Routes::Root.app

module FeatureSpecHelper
  include Rack::Test::Methods
  include Capybara::DSL

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

    account_id
  end

  def login_user email: "test@example.com", password: "testing"
    visit "/"
    fill_in "login", with: email
    fill_in "password", with: password
    click_on "Login"
  end
end

RSpec.configure do |config|
  config.include FeatureSpecHelper, type: :feature

  config.after type: :feature do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
