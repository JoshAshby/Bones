# frozen_string_literal: true

class Forms::EditRepository < Forms::Base
  forme_namespace "repository"

  attribute :id, Forms::Types::Integer
  attribute? :password, Forms::Types::String.optional

  def repository
    @repository ||= DB[:repositories].where(id: id).first
  end

  def save
    return true if password.blank?

    data = DB[:repositories].join(:accounts)
      .where { |o| o.repositories[:id] =~ id }
      .select(:username, :name)
      .first

    repo = Bones::UserFossil.new(data[:username]).repository data[:name]

    repo.change_password username: data[:username], password: password

    true
  end
end
