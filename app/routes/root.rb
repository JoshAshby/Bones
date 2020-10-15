# frozen_string_literal: true

class Routes::Root < Routes::Base
  route do |r|
    check_csrf!
    rodauth.load_memory

    r.public

    r.on "account" do
      r.rodauth
    end

    r.on "user" do
      rodauth.require_authentication
      r.run Routes::User
    end

    r.root do
      view :index
    end
  end
end
