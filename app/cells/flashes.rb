# frozen_string_literal: true

class Cells::Flashes < Cells::Base
  def messages
    @messages ||= model.transform_keys(&:to_s).slice "info", "notice", "warn", "alert"
  end

  def list
    return "" unless messages.any?

    render :list
  end
end
