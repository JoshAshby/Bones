# frozen_string_literal: true

class Routes::Root < Roda
  plugin RequestLogger
  plugin :public

  plugin :render, views: "app/views"
  plugin :content_for

  plugin :run_append_slash

  plugin :forme
  plugin :forme_set, secret: SecureRandom.hex(64)

  plugin :flash

  plugin :route_csrf
  plugin :sessions, secret: SecureRandom.hex(64)

  secret = ENV.delete('SESSION_SECRET') || SecureRandom.random_bytes(64)
  plugin :sessions, secret: secret

  plugin :rodauth, csrf: :route_csrf do
    db DB

    enable :login, :logout, :remember, :reset_password, :create_account, :close_account, :change_password, :change_password_notify

    account_password_hash_column :ph

    hmac_secret secret
  end

  plugin :error_handler do |e|
    @page_title = "Internal Server Error"

    view content: <<~HTML
      #{h e.class}: #{h e.message}
      <br />
      #{e.backtrace.map{|line| h line}.join("<br />")}
    HTML
  end

  plugin :not_found do
    @page_title = "File Not Found"
    view content: ""
  end

  route do |r|
    check_csrf!
    rodauth.load_memory
    r.rodauth

    r.public

    # r.on "user" do
      # rodauth.require_authentication
      # r.run Routes::Secure
    # end

    r.root do
      view :index
    end
  end
end
