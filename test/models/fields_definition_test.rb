require 'test_helper'

class FieldsDefinitionTest < ActiveSupport::TestCase

  class FakeModel < ApplicationRecord
    self.table_name = 'accounts'
    include Fields::Fields

    required_fields_are :required_one, :required_two
    optional_fields_are :optional_one, :optional_two
    default_fields_are :required_one, :optional_one
  end

  attr_reader :provider

  setup do
    @provider = FactoryBot.create(:simple_provider)
  end

  test 'creates default field definitions' do

    assert_empty provider.fields_definitions

    FieldsDefinition.create_defaults!(provider)

    fake_model_fields = provider.fields_definitions.by_target('FieldsDefinitionTest::FakeModel')
    assert_same_elements [['required_one', 'Required one', true], ['optional_one', 'Optional one', false]],
                         fake_model_fields.pluck(:name, :label, :required)

  end

end
