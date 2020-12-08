# frozen_string_literal: true

require "forme/erb"

# Special Forme class for handling Erbse which yields blocks within templates
# as strings. This wraps the blocks result in a Forme.raw statement instead of
# passing the block to the form tag as I couldn't get the latter to output
# correctly
class Forme::Erbse < Forme::Form
  # Create a form tag with the given attributes.
  def form attr={}
    if obj && !attr[:method] && !attr["method"] && obj.respond_to?(:forme_default_request_method)
      attr = attr.merge("method" => obj.forme_default_request_method)
    end

    res = Forme.raw(yield(self).to_s) if block_given?

    tag(:form, attr, [ hidden_form_tags(self), res ]).to_s
  end

  def tag type, attr={}, children=[]
    children << Forme.raw(yield.to_s) if block_given?

    _tag type, attr, children
  end
end
