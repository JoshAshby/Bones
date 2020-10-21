# frozen_string_literal: true

class Formi::Bones::Wrapper < Forme::Wrapper
  Forme.register_transformer :wrapper, :bones, new

  def call tag, input
    case input.type
    when :submit, :button, :reset then [tag]
    else
      [ input.tag(:div, { class: "m-form__input-group" }, tag) ]
    end
  end
end
