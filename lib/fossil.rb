# frozen_string_literal: true

module Fossil
  class Error < StandardError; end
  class ExistingRepositoryError < Error; end
  class FossilCommandError < Error; end

  def self.fossil_binary
    @fossil_binary ||= CONFIG.dig("bones", "fossil_binary")
  end
end
