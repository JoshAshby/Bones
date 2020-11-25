# frozen_string_literal: true

class Cells::FlashMessage < Cells::Base
  def flash_key
    case options[:key]
    when "info" then "Info"
    when "notice" then "Notice"
    when "warn" then "Warning"
    when "alert" then "Alert"
    else "Notice"
    end
  end

  def key
    model[0]
  end

  def message
    model[1]
  end
end
