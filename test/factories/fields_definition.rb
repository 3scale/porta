FactoryBot.define do

  factory(:fields_definition, :class => FieldsDefinition) do
    target 'User'
    sequence(:name) {|n| "name-#{n}" }
    sequence(:label) {|n| "label-#{n}" }
    required false
    association :account, factory: :provider_account
  end
end