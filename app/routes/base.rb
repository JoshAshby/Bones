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

  plugin :forme
  plugin :forme_route_csrf

  def _forme_form_class
    Forme::Erbse
  end

  # def form(obj=nil, attr={}, opts={}, &block)
  # if obj.is_a?(Hash)
  # attribs = obj
  # options = attr = attr.dup
  # else
  # attribs = attr
  # options = opts = opts.dup
  # end

  # apply_csrf = options[:csrf]

  # if apply_csrf || apply_csrf.nil?
  # unless method = attribs[:method] || attribs['method']
  # if obj && !obj.is_a?(Hash) && obj.respond_to?(:forme_default_request_method)
  # method = obj.forme_default_request_method
  # end
  # end
  # end

  # if apply_csrf.nil?
  # apply_csrf = csrf_options[:check_request_methods].include?(method.to_s.upcase)
  # end

  # if apply_csrf
  # token = if options.fetch(:use_request_specific_token){use_request_specific_csrf_tokens?}
  # csrf_token(csrf_path(attribs[:action]), method)
  # else
  # csrf_token
  # end

  # options[:csrf] = [csrf_field, token]
  # options[:hidden_tags] ||= []
  # options[:hidden_tags] += [{csrf_field=>token}]
  # end

  # # options[:output] = @_out_buf if block
  # _forme_form_options(options)
  # form = _forme_form_class.new(obj, opts)

  # # res = yield form

  # # res1 = form.form(attr)

  # binding.irb
  # end

  plugin :flash

  plugin :route_csrf

  plugin :sessions, key: "bones.session", secret: secret
  plugin :shared_vars

  plugin :rodauth, csrf: :route_csrf do
    db DB

    enable :login, :logout, :remember, :close_account,
           :reset_password, :change_password, :change_password_notify,
           :change_login

    hmac_secret secret

    email_from { CONFIG["email_from"] }

    prefix "/account"

    login_label { "Email" }
    change_login_button { "Change Email" }
    change_login_route { "change-email" }

    if Features.enabled? :sign_up
      enable :create_account
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

        # TODO: Move this into a Dry::Validation::Contract that also handles
        # other things like validating emails aren't 'official' ?
        if username[%r{\A[A-Za-z1-9_-]+\z}].nil?
          throw_error_status(422, "username", "must only contain letters, numbers, underscores and dashes")
        end

        account[:username] = username
      end

      after_create_account do
        Bones::UserFossil.new(username: account[:username]).ensure_fs!
      end
    end

    after_login do
      remember_login
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

    view :error, layout: :layout_centered
  end

  plugin(:not_found) { view :not_found, layout: :layout_centered }
end
