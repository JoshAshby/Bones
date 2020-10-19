# frozen_string_literal: true

module Forme
  register_config(
    :bones,
    # formatter: :bones,
    # inputs_wrapper: :bones,
    # wrapper: :bones,
    error_handler: :bones,
    # serializer: :bones,
    # labeler: :bones,
    # tag_wrapper: :bones,
    # set_wrapper: :div
  )

  class ErrorHandler::Bones < ErrorHandler
    Forme.register_transformer :error_handler, :bones, new

    def call tag, input
      if tag.is_a?(Tag)
        puts tag.attr[:class]
        tag.attr[:class] = tag.attr[:class].to_s.gsub(/\s*error\s*/, "")
        tag.attr.delete(:class) if tag.attr[:class].to_s == ""
      end

      attr = input.opts[:error_attr]
      attr = attr ? attr.dup : {}
      Forme.attr_classes(attr, "a-form__error-message")

      return [ tag ] if input.opts[:skip_error_message]

      return [ tag, input.tag(:p, attr, input.opts[:error].join(", ")) ]
    end
  end

  class Formatter::Bones < Formatter
    Forme.register_transformer :formatter, :bones, self
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

    # def call tag, input; end
  end

  class Wrapper::Bones < Wrapper
    Forme.register_transformer :wrapper, :bones, new

    # def call tag, input; end
  end

  class Serializer::Bones < Serializer
    Forme.register_transformer :serializer, :bones, new

    # def call tag; end
  end
end
