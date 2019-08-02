module Fields::Extensions

  module AssociationCollectionExtension

    def build_with_fields(attributes = {}, &block)
      attributes = modify_attributes_with_fields(attributes)
      build(attributes, &block)
    end

    def create_with_fields(attributes = {}, &block)
      attributes = modify_attributes_with_fields(attributes)
      create(attributes, &block)
    end

    private

    # Set :fields_definitions_source to attributes hash
    # source is @owner of association
    # fields overrides initializer to remove this attribute from hash before initialization
    #
    # skips modificatio when @owner is existing record
    # traversing to proper (existing) source root is handled by Fields#fields_definitions_source_root
    #
    def modify_attributes_with_fields attributes
      attributes = attributes.nil? ? {} : attributes.dup

      # this is not possible, because when object is created by association,
      # then attributes like owner_id are set after initializer is run
      # so we cannot lookup fields defininitions source and have to set it this way
      # return attributes unless @owner.new_record?

      klass = proxy_association.klass || proxy_association.reflection.klass
      if klass.respond_to?(:has_fields?) && klass.has_fields?
        if attributes.is_a? Array
          attributes.map! {|attrs| attrs[:fields_definitions_source] = proxy_association.owner }
        else
          attributes[:fields_definitions_source] = proxy_association.owner
        end
      end

      attributes
    end
  end
end
