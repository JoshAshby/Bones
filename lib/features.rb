# frozen_string_literal: true

class Features
  def self.config
    CONFIG
  end

  def self.enabled? flag
    config.dig("feature_flags", flag.to_s) == true
  end
end
