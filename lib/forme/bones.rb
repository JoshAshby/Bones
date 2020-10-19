# frozen_string_literal: true

module Forme
  register_config(
    :bones,
    formatter: :bones,
    # inputs_wrapper: :div,
    wrapper: :bones,
    error_handler: :bones,
    # serializer: :bones,
    labeler: :bones
    # tag_wrapper: :bones,
    # set_wrapper: :div
  )

  class ErrorHandler::Bones < ErrorHandler
    Forme.register_transformer :error_handler, :bones, new

    def call tag, input
      tag.each do |t|
        next unless t.is_a? Tag

        Forme.attr_classes(t.attr, "-error")
      end

      attr = input.opts[:error_attr]
      attr = attr ? attr.dup : {}
      Forme.attr_classes(attr, "a-form__error-message")

      return [ tag ] if input.opts[:skip_error_message]

      [ tag, input.tag(:p, attr, input.opts[:error].join(", ")) ]
    end
  end

  class Formatter::Bones < Formatter
    Forme.register_transformer :formatter, :bones, self

    def call(input)
      @input = input
      @form = input.form
      attr = input.opts[:attr]
      @attr = attr ? attr.dup : {}
      @opts = input.opts
      normalize_options

      @attr[:class] ||= ""

      case input.type
      when :button, :submit, :reset
        Forme.attr_classes(@attr, "a-form__button -primary")
      else
        Forme.attr_classes(@attr, "a-form__input")
      end

      tag = if html = input.opts[:html]
              html = html.call(input) if html.respond_to?(:call)
              form.raw(html)
            else
              convert_to_tag(input.type)
            end

      tag = wrap_tag_with_label(tag) if @opts[:label]
      tag = wrap_tag_with_error(tag) if @opts[:error]
      tag = wrap(:helper, tag) if input.opts[:help]
      wrap_tag(tag)
    end
  end

  class Formatter::BonesReadOnly < Formatter
    Forme.register_transformer :formatter, :bones_readonly, self
  end

  class InputsWrapper::Bones
    Forme.register_transformer :inputs_wrapper, :bones, new

    # def call form, opts, &block; end
  end

  class InputsWrapper::BonesTable
    Forme.register_transformer :inputs_wrapper, :bones_table, new

    # def call form, opts, &block; end
  end

  class Labeler::Bones
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

  class Wrapper::Bones < Wrapper
    Forme.register_transformer :wrapper, :bones, new

    def call tag, input
      case input.type
      when :submit, :button, :reset then [tag]
      else
        [ input.tag(:div, { class: "m-form__input-group" }, tag) ]
      end
    end
  end

  class Serializer::Bones < Serializer
    Forme.register_transformer :serializer, :bones, new

    # def call tag; end
  end
end
