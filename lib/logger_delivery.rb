# frozen_string_literal: true

class LoggerDelivery
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    LOGGER.mail { mail }
  end
end
