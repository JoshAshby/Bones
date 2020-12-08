# frozen_string_literal: true

class Cells::FlashMessage < Cells::Base
  MAPPING = {
    "info" => ["Info", "info", "text-steelblue-600"],
    "notice" => ["Info", "info", "text-steelblue-600"],
    "warn" => ["Warning", "alert-triangle", "text-orange-600"],
    "alert" => ["Alert", "x-octagon", "text-plum-600"]
  }.freeze

  private_constant :MAPPING

  def key
    model[0]
  end

  def message
    model[1]
  end

  def title
    mapping[0]
  end

  def icon
    mapping[1]
  end

  def icon_color
    mapping[2]
  end

  protected

  def mapping
    @mapping ||= MAPPING.fetch key, "info"
  end
end
