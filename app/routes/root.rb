# frozen_string_literal: true

class Routes::Root < Routes::Base
  route do |r|
    r.public

    check_csrf!
    rodauth.load_memory

    shared[:account] = rodauth.account_from_session if rodauth.session_value
    shared[:account] ||= {}
    shared[:breadcrumbs] = []

    r.on "account" do
      set_layout_options template: :layout_centered
      shared[:breadcrumbs] << "Account"

      r.rodauth

      r.is do
        view "account/index", layout: :layout_logged_in
      end
    end

    r.on "dashboard" do
      shared[:breadcrumbs] << "Dashboard"

      rodauth.require_authentication
      r.run Routes::User
    end

    r.get "credits" do
      shared[:breadcrumbs] << "Credits"
      view :credits, layout: :layout_centered
    end

    r.root do
      next r.redirect "/dashboard" if rodauth.logged_in?

      view :index, layout: :layout
    end
  end
end
