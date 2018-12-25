module FieldsDefinitionsHelpers
  def field_defined(provider, options)
    FactoryBot.create :fields_definition, options.merge(:account_id => provider.id)
  end
end
