# frozen_string_literal: true

module Bones
  def self.root
    @root ||= Pathname.new(CONFIG.dig("bones", "repository_root")).expand_path
  end
end
