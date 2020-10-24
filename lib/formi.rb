# frozen_string_literal: true

# Custom Forme config and transformers for Bones' frontend
# :nocov:
module Formi # :nodoc:
  # This is a bit of a hack around Zeitwerk and being lazy with not wanting to
  # setup eager loading for either all of lib/ or for formi itself :|
  # hashtag yolo
  def self.register_to_forme
    Forme.register_transformer :error_handler, :formi, Formi::ErrorHandler.new
    Forme.register_transformer :formatter, :formi, Formi::Formatter
    Forme.register_transformer :labeler, :formi, Formi::Labeler.new
    Forme.register_transformer :wrapper, :formi, Formi::Wrapper.new

    Forme.register_config(
      :formi,
      formatter: :formi,
      # inputs_wrapper: :div,
      wrapper: :formi,
      error_handler: :formi,
      # serializer: :formi,
      labeler: :formi,
      # tag_wrapper: :formi,
      # set_wrapper: :div
    )
  end
end
