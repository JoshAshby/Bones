# frozen_string_literal: true

# :nodoc: all
# :nocov:
class LoggerDelivery
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    LOGGER.mail { mail }
  end
end
