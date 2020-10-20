# frozen_string_literal: true

module Fossil
  def self.fossil_binary
    @fossil_binary ||= CONFIG.dig("bones", "fossil_binary")
  end
end
