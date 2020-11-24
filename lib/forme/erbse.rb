# frozen_string_literal: true

require "forme/erb"

# Special Forme class for handling Erbse
# rubocop:disable Style/EvalWithLocation
class Forme::Erbse < Forme::ERB::Form
  def capture(block="") # :nodoc:
    buf_was = @output
    @output = block.is_a?(Proc) ? (eval("_buf", block.binding) || @output) : block
    yield
    ret = @output
    @output = buf_was
    ret
  end
end
# rubocop:enable Style/EvalWithLocation
