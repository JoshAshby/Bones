# frozen_string_literal: true

class Cli::User::Edit < Dry::CLI::Command
  desc "Edit a user"

  argument :email, desc: "The users email"
  argument :username, desc: "The users username"

  option :status,
         desc: "Status to change the user to. Will ensure the cgi script is present if setting to Verified (2)",
         type: :integer

  attr_reader :params

  def call(**params)
    @params = params

    unless account_id
      puts "Account not found, aborting"
      return
    end

    edit
  end

  private

  def account_id
    @account_id ||= DB[:accounts].where(
      email: params[:email],
      username: params[:username]
    ).get(:id)
  end

  def edit
    set_status params[:status].to_i if params[:status]
  end

  # rubocop:disable Naming/AccessorMethodName
  def set_status status_id
    if status_id == 2
      puts "Please use the `user delete' command instead of setting a users status to Closed"
      return
    end

    DB[:accounts].where(id: account_id).update(status_id: status_id)

    return unless status_id == 2

    user_fossil = Bones::UserFossil.new params[:username]
    user_fossil.ensure_fs!
  end
  # rubocop:enable Naming/AccessorMethodName
end
