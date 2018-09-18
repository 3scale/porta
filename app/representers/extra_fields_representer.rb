module ExtraFieldsRepresenter
  def representable_attrs
    # Representable::Config#clone does not work, just create new one and inherit it
    attrs = Representable::Config.new.inherit!(super)
    representable_extra_fields_attrs.each do |(name, options)|
      attrs.add(name, options)
    end
    attrs
  end

  def representable_extra_fields_attrs
    Array(try(:defined_extra_fields)).map do |field|
      name = field.name
      [ name, { getter: ->(*) { field_value(name) } }]
    end
  end
end
