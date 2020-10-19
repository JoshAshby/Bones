# frozen_string_literal: true

class Routes::Base < Roda
  secret = ENV.fetch("SESSION_SECRET", SecureRandom.random_bytes(64))

  plugin RequestLogger
  plugin :public

  plugin :render, views: "app/views"
  plugin :content_for
  plugin :view_options

  plugin :run_append_slash

  plugin :forme
  plugin :forme_set, secret: secret

  plugin :flash

  plugin :route_csrf

  plugin :sessions, secret: secret
  plugin :shared_vars

  plugin :hooks

  plugin :rodauth, csrf: :route_csrf do
    db DB

    enable :login, :logout, :remember, :close_account,
           :reset_password, :change_password, :change_password_notify,
           :change_login,
           :create_account

    hmac_secret secret

    prefix "/account"
    login_label { "Email" }

    change_login_button { "Change Email" }
    change_login_route { "change-email" }

    create_account_route "create"

    require_login_confirmation? false
    create_account_additional_form_tags <<~HTML
      <div class="form-group">
        <label for="username">Username</label>
        <input name='username' id='username' type="text">
      </div>
    HTML

    before_create_account do
      username = param_or_nil("username")
      throw_error_status(422, "username", "must be present") unless username

      account[:username] = username
    end

    after_create_account do
      Bones::UserFossil.new(username: account[:username]).ensure_fs!
    end

    # before_login_route { scope.set_layout_options template: :layout_centered }
    # login_view { view :index, layout: :layout }

    after_login do
      remember_login

      # username is used a lot for the fossil ops, so lets just cache it
      session[:username] = DB[:accounts].where(id: account[:id]).get(:username)
    end

    logout_redirect { "/" }

    close_account_route "close"
    before_close_account_route do
      scope.set_layout_options template: :layout_logged_in
    end

    before_change_password_route do
      scope.set_layout_options template: :layout_logged_in
    end

    before_change_login_route do
      scope.set_layout_options template: :layout_logged_in
    end
  end

  plugin :error_handler do |e|
    LOGGER.error e

    @exception_code = 500
    @exception = e

    view :error
  end

  plugin :not_found do
    view :not_found, layout: :layout_centered
  end

  after do
    Mail::TestMailer.deliveries.each do |mail|
      LOGGER.mail mail
    end

    Mail::TestMailer.deliveries.clear
  end

  # rubocop:disable Style/HashLikeCase
  def flash_key key
    case key
    when "info" then "Info"
    when "notice" then "Notice"
    when "warn" then "Warning"
    when "alert" then "Alert"
    else "Notice"
    end
  end
  # rubocop:enable Style/HashLikeCase
end
