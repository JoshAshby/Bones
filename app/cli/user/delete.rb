# frozen_string_literal: true

class Cli::User::Delete < Dry::CLI::Command
  desc <<~DESC
    Deletes a user, defaulting to a soft delete by closing their account and removing their repositories cgi script."
  DESC

  argument :email, desc: "The users email"
  argument :username, desc: "The users username"

  option :hard_delete, desc: "EXTERMINATE EXTERMINATE EXTERMINATE", type: :boolean

  attr_reader :params

  def call(**params)
    @params = params

    unless account_id
      puts "Account not found, aborting"
      return
    end

    delete
  end

  private

  def account_id
    @account_id ||= DB[:accounts].where(
      email: params[:email],
      username: params[:username]
    ).get(:id)
  end

  def delete
    return soft_delete unless params[:hard_delete]

    hard_delete
  end

  def soft_delete
    DB[:accounts].where(id: account_id).update(status_id: 3)

    user_fossil = Bones::UserFossil.new params[:username]
    user_fossil.remove_cgi_script
  end

  def hard_delete
    puts "Please retype the users username and press enter to confirm that:"
    puts "you do indeed want to DELETE all this users data and their repositories."
    puts "EVERYTHING."

    print ">"
    prompted_username = $stdin.gets

    if prompted_username.strip != params[:username]
      puts "Username did not match, aborting"
      return
    end

    DB[:account_password_hashes].where(id: account_id).delete
    DB[:accounts].where(id: account_id).delete

    user_fossil = Bones::UserFossil.new params[:username]
    user_fossil.repositories.each(&:delete_repository!)
  end
end
