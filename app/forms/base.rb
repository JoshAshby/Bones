# frozen_string_literal: true

class Forms::Base < Dry::Struct
  def self.forme_namespace name=nil
    @forme_namespace = name if name
    @forme_namespace
  end

  def self.from_params params
    init_params = params[forme_namespace]
    init_params = yield init_params if block_given?
    new init_params
  end

  attr_reader :errors

  # Tell dry-struct that even with string keys we want them to really be
  # symbols. This is great for .from_params above
  transform_keys(&:to_sym)

  def forme_config form
    form.namespaces << self.class.forme_namespace

    form_errors = errors&.transform_keys(&:to_s)
    form.opts[:errors] = { self.class.forme_namespace.to_s => form_errors }
  end
end
