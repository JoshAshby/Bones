# frozen_string_literal: true

class Cells::Base < Cell::ViewModel
  include ::Cell::Erb

  include ViewHelpers

  # head-scratcher
  self.view_paths = ["app"]

  def self.class_from_cell_name name
    util.constant_for "cells/#{ name }"
  end
end
