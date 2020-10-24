# frozen_string_literal: true

class Formi::Wrapper < Forme::Wrapper # :nodoc: all
  def call tag, input
    case input.type
    when :submit, :button, :reset then [tag]
    else
      [ input.tag(:div, { class: "m-form__input-group" }, tag) ]
    end
  end
end
