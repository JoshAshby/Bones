# frozen_string_literal: true

# :nocov:
module Formi # :nodoc:
  # This is a bit of a hack around Zeitwerk and being lazy with not wanting to
  # setup eager loading for either all of lib/ or for formi itself :|
  # hashtag yolo
  def self.register_to_forme
    Forme.register_transformer :error_handler, :bones, Formi::Bones::ErrorHandler.new
    Forme.register_transformer :formatter, :bones, Formi::Bones::Formatter
    Forme.register_transformer :labeler, :bones, Formi::Bones::Labeler.new
    Forme.register_transformer :wrapper, :bones, Formi::Bones::Wrapper.new

    Forme.register_config(
      :formi,
      formatter: :bones,
      # inputs_wrapper: :div,
      wrapper: :bones,
      error_handler: :bones,
      # serializer: :bones,
      labeler: :bones
      # tag_wrapper: :bones,
      # set_wrapper: :div
    )
  end
end
