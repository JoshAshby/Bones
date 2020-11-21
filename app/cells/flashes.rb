class Cells::Flashes < Cells::Base
  def messages
    model.slice "info", "notice", "warn", "alert"
  end
end
