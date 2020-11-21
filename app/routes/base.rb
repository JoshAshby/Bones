# frozen_string_literal: true

module ViewHelpers
  def inline_svg ident, **attrs
    raw_svg = File.open("public/#{ ident }.svg") do |f|
      f.read
    end

    with_svg(raw_svg) do |svg|
      if attrs[:class]
        classes = (svg["class"] || "").split(" ")
        classes << attrs[:class]
        svg["class"] = classes.join(" ")
      end
    end.to_html
  end

  def undraw_svg ident, **attrs
    ident = "undraw_#{ ident }" unless ident.start_with? "undraw_"
    inline_svg("undraw/#{ ident }", **attrs)
  end

  def feather_svg ident, **attrs
    inline_svg("feather/#{ ident }", **attrs)
  end

  def with_svg(doc)
    doc = Nokogiri::XML::Document.parse(doc, nil, "UTF-8")
    svg = doc.at_css "svg"
    yield svg if svg && block_given?
    doc
  end

  def cell(name, model=nil, options={}, constant=::Cell::ViewModel, &block)
    options[:context] ||= {}
    options[:context][:controller] = self

    constant.cell(name, model, options, &block)
  end
end

class Routes::Base < Roda
  secret = ENV.fetch("SESSION_SECRET", SecureRandom.random_bytes(64))

  include ViewHelpers

  plugin RequestLogger
  plugin :public

  plugin(
    :render,
    views: "app/templates",
    template_opts: {
      engine_class: Erubi::CaptureEndEngine,
      outvar: "@_out_buf"
    }
  )

  plugin :content_for
  plugin :view_options

  plugin :run_append_slash

  plugin :forme
  plugin :forme_set, secret: secret

  plugin :flash

  plugin :route_csrf

  plugin :sessions, key: "bones.session", secret: secret
  plugin :shared_vars

  plugin :hooks

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

  plugin :not_found do
    view :not_found, layout: :layout_centered
  end
end
