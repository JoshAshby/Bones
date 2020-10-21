# frozen_string_literal: true

class Formi::Bones::Labeler
  Forme.register_transformer :labeler, :bones, new

  def call tag, input
    label = input.opts[:label]

    attr = input.opts[:label_attr]
    attr = attr ? attr.dup : {}
    Forme.attr_classes(attr, "a-form__label")

    label += "*" if input.opts[:required] && !label.end_with?("*")

    case input.type
    when :submit then [tag]
    else
      [ input.tag(:label, attr, label), tag ]
    end
  end
end
