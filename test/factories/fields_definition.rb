Factory.define(:fields_definition, :class => FieldsDefinition) do |fd|
  fd.target 'User'
  fd.sequence(:name) {|n| "name-#{n}" }
  fd.sequence(:label) {|n| "label-#{n}" }
  fd.required false
  fd.association :account, factory: :provider_account
end
