# frozen_string_literal: true

class Routes::Base < Roda
  secret = ENV.fetch("SESSION_SECRET", SecureRandom.random_bytes(64))

  include ViewHelpers

  plugin RequestLogger
  plugin :public

  plugin(
    :render,
    views: "app/templates"
  )

  plugin :content_for
  plugin :view_options

  plugin :run_append_slash
  plugin :route_csrf

  plugin :forme
  plugin :forme_route_csrf

  def _forme_form_class
    Forme::Erbse
  end

  plugin :sessions, key: "bones.session", secret: secret
  plugin :shared_vars
  plugin :flash

  plugin :rodauth, csrf: :route_csrf do
    db DB

    enable :login, :logout, :remember, :close_account,
           :reset_password, :change_password, :change_password_notify,
           :change_login

    hmac_secret secret

    session_key_prefix "bones_"
    remember_cookie_key "_bones_remember"

    email_from CONFIG["email_from"]

    prefix "/account"

    login_view { scope.view "account/login", layout: :layout_centered }
    after_login { remember_login }

    logout_redirect "/"

    reset_password_request_view { scope.view "account/forgot_password", layout: :layout_centered }
    reset_password_view { scope.view "account/reset_password", layout: :layout_centered }

    change_login_route "change-email"
    change_login_view { scope.view "account/change_email", layout: :layout_logged_in }

    change_password_view { scope.view "account/change_password", layout: :layout_logged_in }

    close_account_route "close"
    close_account_view { scope.view "account/close_account", layout: :layout_logged_in }

    if Features.enabled? :sign_up
      enable :create_account

      create_account_route "create"
      create_account_view { scope.view "account/signup" }

      require_login_confirmation? false

      before_create_account do
        username = param_or_nil("username")
        throw_error_status(422, "username", "must be present") unless username

        # TODO: Move this into a Dry::Validation::Contract that also handles
        # other things like validating emails aren't 'official' ?
        if username[%r{\A[A-Za-z1-9_-]+\z}].nil?
          throw_error_status(422, "username", "must only contain letters, numbers, underscores and dashes")
        end

        account[:username] = username
      end

      after_create_account do
        Bones::UserFossil.new(account[:username]).ensure_fs!
      end
    end
  end

  plugin :error_handler do |e|
    LOGGER.error e

    @exception_code = 500
    @exception = e

    view :error, layout: :layout_centered
  end

  plugin(:not_found) { view :not_found, layout: :layout_centered }
end
