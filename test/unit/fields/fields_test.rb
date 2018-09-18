require 'test_helper'

class Fields::FieldsTest < ActiveSupport::TestCase
  class Model < ActiveRecord::Base
    self.table_name = 'accounts'
    include Fields::Fields

    set_fields_source :self

    def self.columns
      []
    end

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
end
