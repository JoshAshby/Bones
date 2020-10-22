# frozen_string_literal: true

class Formi::Bones::ErrorHandler < Forme::ErrorHandler # :nodoc: all
  def call tag, input
    tag.each do |t|
      next unless t.is_a? Forme::Tag

      Forme.attr_classes(t.attr, "-error")
    end

    attr = input.opts[:error_attr]
    attr = attr ? attr.dup : {}
    Forme.attr_classes(attr, "a-form__error-message")

    return [ tag ] if input.opts[:skip_error_message]

    [ tag, input.tag(:p, attr, input.opts[:error].join(", ")) ]
  end
end
