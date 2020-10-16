# frozen_string_literal: true

class Routes::Base < Roda
  secret = ENV.delete("SESSION_SECRET") || SecureRandom.random_bytes(64)

  plugin RequestLogger
  plugin :public

  plugin :render, views: "app/views"
  plugin :content_for

  plugin :run_append_slash

  plugin :forme
  plugin :forme_set, secret: secret

  plugin :flash

  plugin :route_csrf

  plugin :sessions, secret: secret

  plugin :rodauth, csrf: :route_csrf do
    db DB

    enable :login, :logout, :remember, :close_account,
           :reset_password, :change_password, :change_password_notify,
           :create_account

    hmac_secret secret

    prefix "/account"
    create_account_route "create"

    require_login_confirmation? false
    create_account_additional_form_tags <<~HTML
      <div class="form-group">
        <label for="username">Username:</label>
        <input name='username' id='username' type="text">
      </div>
    HTML

    before_create_account do
      username = param_or_nil("username")
      throw_error_status(422, "username", "must be present") unless username

      account[:username] = username
    end
  end

  plugin :error_handler do |e|
    @page_title = "Internal Server Error"

    view content: <<~HTML
      #{ h e.class }: #{ h e.message }
      <br />
      #{ e.backtrace.map { |line| h line }.join('<br />') }
    HTML
  end

  plugin :not_found do
    @page_title = "File Not Found"
    view content: <<~HTML
      <h4>404 Not Found :(</h4>
    HTML
  end
end
