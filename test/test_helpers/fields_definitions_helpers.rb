module FieldsDefinitionsHelpers
  def field_defined(provider, options)
    Factory :fields_definition, options.merge(:account_id => provider.id)
  end
end
