# frozen_string_literal: true

module Fossil
  def self.fossil_binary
    ENV["FOSSIL_BINARY"]
  end
end
