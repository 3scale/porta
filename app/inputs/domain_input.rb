# frozen_string_literal: true

class DomainInput < Formtastic::Inputs::StringInput
  def to_html
    input_wrapping do
      label_html <<
      builder.text_field(method, input_html_options) <<
      template.tag.strong(".3scale.net")
    end
  end
end
