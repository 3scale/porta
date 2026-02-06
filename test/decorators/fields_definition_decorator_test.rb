# frozen_string_literal: true

require 'test_helper'

class FieldsDefinitionDecoratorTest < Draper::TestCase
  test "application_defined_fields_data formats input names for all field types" do
    provider = FactoryBot.create(:simple_provider)

    FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance', name: 'custom_field')
    FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance', name: 'name')
    FactoryBot.create(:fields_definition, account: provider, target: 'Cinstance', name: 'description')

    provider.stubs(:extra_field?).with('custom_field').returns(true)
    provider.stubs(:extra_field?).with('name').returns(false)
    provider.stubs(:extra_field?).with('description').returns(false)

    provider.stubs(:internal_field?).with('name').returns(true)
    provider.stubs(:internal_field?).with('description').returns(false)

    # Replicate what application_defined_fields_data does
    custom, name, description = provider.fields_definitions
                                        .where(target: 'Cinstance')
                                        .map { |field| field.decorate.new_application_data(provider) }

    assert_equal 'cinstance[extra_fields][custom_field]', custom[:name]
    assert_equal :extra, custom[:type]

    assert_equal 'cinstance[name]', name[:name]
    assert_equal :internal, name[:type]

    assert_equal 'cinstance[description]', description[:name]
    assert_equal :builtin, description[:type]
  end
end
