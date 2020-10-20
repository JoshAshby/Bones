# frozen_string_literal: true

class Features
  class UnknownFeatureError < StandardError; end

  def self.config
    CONFIG
  end

  # Test if a feature flag is enabled or not, and failing when an unknown
  # feature flag is tested for.
  #
  # @raises StandardError if
  def self.enabled? flag, quiet: false
    flag_config = config.dig "feature_flags", flag.to_s
    fail UnknownFeatureError, "Unknown feature #{ flag }" if flag_config.nil? && !quiet

    flag_config == true
  end
end
