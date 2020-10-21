# frozen_string_literal: true

# Mail delivery method that logs out the the apps tty-logger instance
# since the default logger delivery method doesn't play nicely tty-logger
class DeliveryLogger
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    LOGGER.mail { mail }
  end
end
