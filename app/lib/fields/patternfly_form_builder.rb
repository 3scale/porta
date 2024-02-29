# frozen_string_literal: true

class Fields::PatternflyFormBuilder < Fields::FormBuilder
  def output_html(field, options = {})
    typed_input_field = input_field(field, options)
    builder_options = typed_input_field.builder_options

    default_type = default_input_type(field.name.to_sym, builder_options)
    type = default_type == :select ? :patternfly_select : :patternfly_input

    typed_input_field.input(self, builder_options.merge({ as: type }))
  end
end
