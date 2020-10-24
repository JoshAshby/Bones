# frozen_string_literal: true

class Formi::Formatter < Forme::Formatter # :nodoc: all
  # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity,Lint/AssignmentInCondition
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
  # rubocop:enable Metrics/AbcSize,Metrics/PerceivedComplexity,Lint/AssignmentInCondition
end
