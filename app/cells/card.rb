# frozen_string_literal: true

class Cells::Card < Cells::Base
  def title
    options[:title]
  end

  def icon
    options[:icon][:icon] || "thumbs-up"
  end

  def icon_color
    options[:icon][:color] || "blue"
  end
end
