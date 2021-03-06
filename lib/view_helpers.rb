# frozen_string_literal: true

module ViewHelpers
  def inline_svg ident, **attrs
    raw_svg = File.open("public/#{ ident }.svg", &:read)

    with_svg(raw_svg) do |svg|
      svg.add_class attrs.delete(:class) if attrs[:class]

      attrs.each { svg.set_attribute _1, _2 }
    end.to_html
  end

  def undraw_svg ident, **attrs
    ident = "undraw_#{ ident }" unless ident.start_with? "undraw_"
    inline_svg("undraw/#{ ident }", **attrs)
  end

  def feather_svg ident, **attrs
    inline_svg("feather/#{ ident }", **attrs)
  end

  def cell(name, model=nil, options={}, constant=::Cell::ViewModel, &block)
    options[:context] ||= {}
    options[:context][:controller] = self

    constant.cell(name, model, options, &block)
  end

  def capture
    yield
  end

  protected

  def with_svg(doc)
    doc = Nokogiri::XML::Document.parse(doc, nil, "UTF-8")
    svg = doc.at_css "svg"
    yield svg if svg && block_given?
    doc
  end
end
