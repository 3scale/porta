module FieldsRepresenter

  module JSON
    def representable_attrs
      attrs = Representable::Config.new.inherit!(super)
      representable_fields_attrs.each do |(name, options)|
        attrs.add(name, options)
      end
      attrs
    end

    def representable_fields_attrs
      Array(represented.try(:defined_builtin_fields)).map do |field|
        name = field.name
        [
          name,
          {
            getter: ->(*) {
              value = field_value(name)

              value.respond_to?(:to_hash) ? value.to_hash : value
            }
          }
        ]
      end
    end
  end

  module XML
    def representable_attrs
      attrs = Representable::Config.new.inherit!(super)
      representable_fields_attrs.each do |(name, options)|
        attrs.add(name, options)
      end
      attrs
    end

    def representable_fields_attrs
      Array(represented.try(:defined_builtin_fields)).map do |field|
        name = field.name
        [
          name,
          {
            getter: ->(*) {
              value = field_value(name)

              xml = ThreeScale::XML::Builder.new(skip_instruct: true)
              if value.respond_to?(:to_xml)
                value.to_xml(builder: xml, root: name)
              else
                xml.tag!(name.to_s.sub(/_\Z/, ''), value.to_s.strip)
              end
            }
          }
        ]
      end
    end
  end
end
