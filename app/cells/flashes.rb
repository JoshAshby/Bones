# frozen_string_literal: true

class Cells::Flashes < Cells::Base
  def messages
    model.transform_keys(&:to_s).slice "info", "notice", "warn", "alert"
  end

  def list
    return "" unless model.any?

    render :list
  end
end
