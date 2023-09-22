# frozen_string_literal: true

class FieldsDefinitionDecorator < ApplicationDecorator
  self.include_root_in_json = false

  def new_application_data(provider)
    type = field_type(provider)
    input_name = "#{target.downcase}#{type == 'extra' ? '[extra_fields]' : ''}[#{name}]"
    required_value = name != 'description' # Set required to false for the description field
    {
      hidden: hidden,
      required: required_value,
      label: label,
      name: input_name,
      id: input_name,
      choices: choices.any? ? choices : nil,
      hint: hint,
      readOnly: read_only,
      type: type
    }.compact
  end

  def field_type(provider)
    if provider.extra_field?(name)
      :extra
    elsif provider.internal_field?(name)
      :internal
    else
      :builtin
    end
  end
end
