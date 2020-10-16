# frozen_string_literal: true

module Bones
  def self.root
    @root ||= Pathname.new(ENV["REPO_ROOT"]).expand_path
  end
end
