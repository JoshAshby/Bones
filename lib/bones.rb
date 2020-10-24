# frozen_string_literal: true

module Bones
  class Config
    attr_reader :root

    def root= val
      @root = Pathname.new(val).expand_path
    end
  end

  class << self
    attr_accessor :config

    def configure
      self.config ||= Config.new
      yield config
    end
  end
end
