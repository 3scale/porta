module CodeHelper

  def highlighted_code(lang = nil, &block)
    text = capture(&block)
    content_tag( :pre, (content_tag( :code, text, :class => "language-#{lang}")))
  end
end
