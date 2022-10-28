class CodemirrorInput
  include Formtastic::Inputs::Base

  def to_html
    codemirror_options = options.delete(:options) || {}
    input_wrapping do
      label_html <<
      builder.text_area(method, input_html_options) <<
      template.render('/provider/admin/cms/codemirror', html_id: "cms_template_#{method}",
                                                        options: codemirror_options,
                                                        content_type: object.content_type,
                                                        liquid_enabled: object.liquid_enabled)
    end
  end

  def input_html_options
    super.merge(options.slice(:value)).merge({ class: 'mousetrap' })
  end
end
