class Fields::InternalField < Fields::BaseField

  def input(builder)
    builder.input(@name.to_sym, builder_options.merge({input_html: {readonly: true, disabled: true}})).html_safe
  end

end
