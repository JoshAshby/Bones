# frozen_string_literal: true

class Bones::Cli::CreateUserCommand
  include TTY::Option

  usage do
    command "create"
    desc "Create a new user"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  argument :email do
    required
    desc "The email of the user"
  end

  argument :username do
    required
    desc "The username of the user"
  end

  option :password do
    desc "The users password. Leave blank to autogenerate one."
  end

  def help_me
    return unless params[:help]

    print help
    exit
  end

  def validate_me
    return if params.valid?

    puts params.errors.summary
    print help
    exit
  end

  def password
    @pass = params[:password]
    @pass = SecureRandom.hex(20) unless params[:password]

    @pass
  end

  # rubocop:disable Metrics/AbcSize
  def run
    help_me
    validate_me

    require_relative "../env"

    account_id = DB[:accounts].insert(
      email: params[:email],
      username: params[:username],
      status_id: 2 # verified
    )

    DB[:account_password_hashes].insert(
      id: account_id,
      password_hash: BCrypt::Password.create(password).to_s
    )

    Bones::UserFossil.new(username: params[:username]).ensure_fs!

    puts "Created user #{ params[:username] }"
    puts "  email: #{ params[:email] }"
    puts "  password: #{ password }" unless params[:password]
  rescue Sequel::UniqueConstraintViolation => e
    puts "Uh oh, this is embarrassing, something went wrong!"
    puts e.wrapped_exception.message
  end
  # rubocop:enable Metrics/AbcSize
end
