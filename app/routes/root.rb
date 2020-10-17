# frozen_string_literal: true

class Routes::Root < Routes::Base
  route do |r|
    r.public

    check_csrf!

    rodauth.load_memory

    shared[:account] = DB[:accounts].where(id: rodauth.session_value).first || {}
    shared[:breadcrumbs] = []

    r.on "account" do
      shared[:breadcrumbs] << "Account"
      r.root { view :index }
      r.rodauth
    end

    r.on "dashboard" do
      shared[:breadcrumbs] << "Dashboard"
      rodauth.require_authentication
      r.run Routes::User
    end

    r.get("credits") do
      shared[:breadcrumbs] << "Credits"
      view :credits
    end

    r.root { view :index }
  end
end
