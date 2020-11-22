# frozen_string_literal: true

class Cells::HeroSplit < Cells::Base
  def undraw
    options[:undraw]
  end

  def show
    render do
      yield self
    end
  end

  def title text=nil, &block
    block ||= -> { text }
    cell(Cells::HeroSplit::Title).call &block
  end

  def subtitle text=nil, &block
    block ||= -> { text }
    cell(Cells::HeroSplit::Subtitle).call &block
  end
end
