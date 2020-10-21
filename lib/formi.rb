# frozen_string_literal: true

module Formi
  Forme.register_config(
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
end
