# frozen_string_literal: true

class Fields::InternalField < Fields::BaseField

  def input(builder, options = builder_options)
    builder.input(@name.to_sym, options.merge({input_html: {readonly: true, disabled: true}})).html_safe
  end

end
