require 'test_helper'

class Fields::FieldsTest < ActiveSupport::TestCase
  class Model < ActiveRecord::Base
    self.table_name = 'accounts'
    include Fields::Fields

    set_fields_source :self

    attr_reader :provider_account

    def buyer?
      false
    end

    def master?
      true
    end

    def provider?
      true
    end

    def provider_account
      self
    end

    def fields_definitions
      FieldsDefinition.none
    end
  end

  def test_field_label
    model = Model.new
    model.stubs(new_record?: false)

    assert_equal 'Email', model.field_label('email')
  end

  def test_visible_defined_fields
    visible_field = mock('field', visible_for?: true)
    hidden_field = mock('field', visible_for?: false)
    model = Model.new
    model.stubs(:defined_fields).returns([visible_field, hidden_field])
    assert [visible_field], model.visible_defined_fields_for(mock('user'))
  end

  def test_editable_defined_fields
    editable_field = mock('field', editable_by?: true)
    forbidden_field = mock('field', editable_by?: false)
    model = Model.new
    model.stubs(:defined_fields).returns([editable_field, forbidden_field])
    assert [editable_field], model.editable_defined_fields_for(mock('user'))
  end

  def test_fields_definitions_source!
    model = Model.new
    model.expects(:nil_method).returns(nil)
    Model.expects(fields_source_object: :nil_method).at_least_once
    assert_raise Fields::Fields::NoFieldsDefinitionsSource do
      model.fields_definitions_source!
    end
  end

  def test_defined_fields_names
    field1 = mock('field', name: 'field1')
    field2 = mock('field', name: 'field2')
    model = Model.new
    model.stubs(:defined_fields).returns([field1, field2])
    assert_same_elements %w[field1 field2], model.defined_fields_names
  end

  def test_defined_extra_fields_names
    extra_field = mock('field', name: 'extra')
    builtin_field = mock('field')
    model = Model.new
    model.stubs(:defined_fields).returns([extra_field, builtin_field])
    model.stubs(:defined_builtin_fields).returns([builtin_field])
    assert_equal %w[extra], model.defined_extra_fields_names
  end

  def test_defined_builtin_fields_names
    field1 = mock('field', name: 'field1')
    field2 = mock('field', name: 'field2')
    model = Model.new
    model.stubs(:defined_builtin_fields).returns([field1, field2])
    assert_same_elements %w[field1 field2], model.defined_builtin_fields_names
  end
end
