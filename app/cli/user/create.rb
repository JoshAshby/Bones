# frozen_string_literal: true

class Cli::User::Create < Dry::CLI::Command
  desc "Creates a new user"

  argument :email, desc: "The new users email"
  argument :username, desc: "The new users username"
  option :password, desc: "The new users password; Leave blank to autogenerate one"

  attr_reader :params

  def call(**params)
    @params = params
    run
  end

  private

  def password
    @pass = params[:password]
    @pass = SecureRandom.hex(20) unless params[:password]

    @pass
  end

  def run
    account_id = DB[:accounts].insert(
      email: params[:email],
      username: params[:username],
      status_id: 2 # verified
    )

    DB[:account_password_hashes].insert(
      id: account_id,
      password_hash: BCrypt::Password.create(password).to_s
    )

    Bones::UserFossil.new(params[:username]).ensure_fs!

    puts "Created user #{ params[:username] }"
    puts "  email: #{ params[:email] }"
    puts "  password: #{ password }" unless params[:password]
  rescue Sequel::UniqueConstraintViolation => e
    puts "Uh oh, this is embarrassing, something went wrong!"
    puts e.wrapped_exception.message
  end
end
