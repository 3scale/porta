module FieldsRepresenter
  def representable_attrs
    # Representable::Config#clone does not work, just create new one and inherit it
    attrs = Representable::Config.new.inherit!(super)
    representable_fields_attrs.each do |(name, options)|
      attrs.add(name, options)
    end
    attrs
  end

  def representable_fields_attrs
    Array(represented.try(:defined_builtin_fields)).map do |field|
      name = field.name
      # TODO: this is wrong for JSON!
      [
        name,
        {
          getter: ->(*) {
            v = field_value(name)

            # v

            # v.try(:to_xml, builder: ThreeScale::XML::Builder.new(skip_instruct: true)) || v.to_s.strip
            # v.try(:to_xml, builder: Nokogiri::XML::Builder.new, skip_instruct: true) || v.to_s.strip

            # xml = ThreeScale::XML::Builder.new(skip_instruct: true)
            # if v.respond_to?(:to_xml)
            #   v.to_xml(builder: xml, root: name)
            # else
            #   xml.__send__(:method_missing, name, v.to_s.strip)
            # end

            # TODO: this is not working because it returns this:
                    # #(Element:0x3fc4e86f1ef8 {
                    # name = "billing_address",
                    # children = [
                    #   #(Text "<billing_address><company>Tim</company><address>first line\n" +
                    #     "second line</address><address1>first line</address1><address2>second line</address2><phone_number>+123 456 789</phone_number><city>Timbuktu</city><country>ES</country><state>Mali</state><zip>10100</zip></billing_address>")]
                    # })
            # which means that it returns a billing address containing a billing address (the root is twice ...) and the children are text and not node elements
            xml = ThreeScale::XML::Builder.new(skip_instruct: true)
            if v.respond_to?(:to_xml)
              v.to_xml(builder: xml, root: name)
            else
              xml.tag!(name.to_s.sub(/_\Z/, ''), v.to_s.strip)
            end
          }
        }
      ]
    end
  end
end
