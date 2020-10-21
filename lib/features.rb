# frozen_string_literal: true

class Features
  # Raised if a feature flag isn't known to ensure typos on flags don't happen.
  class UnknownFeatureError < StandardError; end

  def self.config # :nodoc:
    CONFIG
  end

  # Test if a feature flag is enabled or not, and failing when an unknown
  # feature flag is tested for.
  #
  # Raises rdoc-ref:Features::UnknownFeatureError if the feature isn't know and
  # the quiet flag was not set.
  def self.enabled? flag, quiet: false
    flag_config = config.dig "feature_flags", flag.to_s
    fail UnknownFeatureError, "Unknown feature #{ flag }" if flag_config.nil? && !quiet

    flag_config == true
  end
end
