module FieldsRepresenter
  def representable_attrs
    attrs = super
    representable_fields_attrs.each do |(name, options)|
      attrs.add(name, options)
    end
    attrs
  end

  def representable_fields_attrs
    Array(try(:defined_builtin_fields)).map do |field|
      name = field.name
      [name, { getter: ->(options){ field_value(name) } }]
    end
  end
end
