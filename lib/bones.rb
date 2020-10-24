# frozen_string_literal: true

module Bones
  module_function

  def root
    @root ||= Pathname.new(CONFIG.dig("bones", "repository_root")).expand_path
  end
end
