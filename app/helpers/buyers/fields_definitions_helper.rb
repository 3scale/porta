module Buyers::FieldsDefinitionsHelper

  def show_if_present(method, object)
    if object.field_value(method.to_s).present?
      content_tag(:tr) do
        content_tag(:th, object.field_label(method.to_s)) + content_tag(:td, h(object.field_value(method.to_s)))
      end.html_safe
    end
  end

  def fields_definitions_rows(object, excluded_fields = [])
    return unless object.defined_fields.present?
    fields = ''
    object.defined_fields.reject{ |f| excluded_fields.include? f.name }.each do |field|
      if object.field(field.name).present? && field.visible_for?(current_user)
        fields << show_if_present(field.name, object).to_s
      end
    end
    fields.html_safe
  end

end
