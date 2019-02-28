# frozen_string_literal: true

require 'test_helper'

class ThreeScale::JSONValidatorTest < ActiveSupport::TestCase
  setup do
    @klass = ThreeScale::JSONValidator
  end

  test 'autoload schema files' do
    schema_files = @klass.send(:autoloaded_schema_files)
    schema_files_count = schema_files.count
    ::JSON::Validator.expects(:add_schema).times(schema_files_count)
    @klass.autoload_schemas
  end

  test 'extract the schema draft' do
    assert_equal 4, @klass.send(:schema_draft, { '$schema' => 'http://json-schema.org/draft-04/schema#' })
    assert_equal 7, @klass.send(:schema_draft, { '$schema' => 'http://json-schema.org/draft-07/schema#' })
    assert_equal 0, @klass.send(:schema_draft, {})
  end

  test 'extract the schema id' do
    assert_equal 'my-id', @klass.send(:schema_id, { 'id' => 'my-id', '$schema' => 'http://json-schema.org/draft-04/schema#' })
    assert_equal 'my-id', @klass.send(:schema_id, { '$id' => 'my-id', '$schema' => 'http://json-schema.org/draft-07/schema#' })
  end

  test 'schema build' do
    schema_json = { '$id' => 'http://example.com/schema-v1/my-schema#frag', '$schema' => 'http://json-schema.org/draft-07/schema#' }
    schema = @klass.build_schema schema_json
    assert_kind_of JSON::Schema, schema
  end

  test 'fully validate' do
    json = { json_key: 'json_value' }
    schema = {}
    validator = @klass.new(json)
    @klass.expects(:fully_validate).with(schema, json, any_parameters)
    validator.fully_validate(schema)
  end
end
