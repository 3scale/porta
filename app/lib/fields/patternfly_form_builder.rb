# frozen_string_literal: true

class Fields::PatternflyFormBuilder < Fields::FormBuilder
  def output_html(field, options = {})
    input_type = field.choices.present? ? :patternfly_select : :patternfly_input
    super(field, options.merge(as: input_type))
  end
end
