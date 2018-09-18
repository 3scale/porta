# Inheriting because the ThreeScale::SemanticFormBuilder contains
# some ready made input fields such as price_input or cancel_button.
#
class Fields::FormBuilder < ThreeScale::SemanticFormBuilder

  # The .join is important as in Ruby 1.9 the Array#to_s method has a different
  # output and that's ERB calls
  # Creates form with all fields of the model.
  #
  def user_defined_form(show_readonly_inputs: true)
    defined_fields = @object.defined_fields
    user = @template.current_user
    editable_fields = defined_fields.select do |field|
      field.editable_by?(user) && (show_readonly_inputs || !field.read_only)
    end

    editable_fields.collect do |field|
      output_html(field)
    end.join.html_safe
  end

  def field(field_name, options = {})
    field = @object.field(field_name)
    unless field.nil?
      output_html(field, options).html_safe
    end
  end

  def field_label(field_name)
    @object.field_label(field_name)
  end

  def output_html(field, options = {})
    opts = field.attributes.dup.merge(options)

    input_field = if @object.extra_field?(field.name)
                    Fields::ExtraField.new(opts)
                  elsif @object.internal_field?(field.name)
                    Fields::InternalField.new(opts)
                  else
                    Fields::BuiltinField.new(opts)
                  end
    input_field.input(self)
  end
end
