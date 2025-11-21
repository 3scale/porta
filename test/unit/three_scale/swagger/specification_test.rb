# frozen_string_literal: true

require "test_helper"

class ThreeScale::Swagger::SpecificationTest < ActiveSupport::TestCase
  module FixtureHelper
    def fixture_spec(fixture_file_name)
      ThreeScale::Swagger::Specification.new(file_fixture("swagger/#{fixture_file_name}.json").read)
    end
  end

  class V10Test < ActiveSupport::TestCase
    include FixtureHelper
    test "valid swagger 1.0 spec" do
      specification = fixture_spec('pet-store-1.0')
      assert specification.valid?, 'specification should be valid'
      assert_equal "1.0", specification.swagger_version
    end

    test "invalid swagger 1.0 with body and query paramTypes" do
      specification = fixture_spec('invalid-1.0')
      assert_not specification.valid?
      errors = specification.errors.full_messages_for(:base)
      assert_equal 1, errors.size, "Should have exactly 1 validation error"
      assert errors.first.include?("paramType='body' and paramType='query'"), "Should error on mixed paramTypes"
    end

    test "swagger 1.0 is not swagger?" do
      specification = fixture_spec('pet-store-1.0')
      assert_not specification.swagger?, "Swagger 1.0 should not be considered swagger? (for swagger-ui)"
    end
  end

  class V12Test < ActiveSupport::TestCase
    include FixtureHelper

    test "valid swagger 1.2 spec" do
      specification = fixture_spec('pet-resource-1.2')
      assert specification.valid?, 'specification should be valid'
      assert_equal "1.2", specification.swagger_version
    end

    test "swagger 1.2 is swagger?" do
      specification = fixture_spec('pet-resource-1.2')
      assert specification.swagger?, "Swagger 1.2 should be considered swagger? (for swagger-ui)"
    end

    test "json_schema is memoized at class level" do
      # First call should parse the schema
      schema1 = ThreeScale::Swagger::Specification::V12.json_schema

      # Second call should return the same object (not re-parse)
      schema2 = ThreeScale::Swagger::Specification::V12.json_schema

      assert_same schema1, schema2, "Schema should be memoized at class level"
      assert schema1.frozen?, "Schema should be frozen"
    end

    test "uses monolithic schema file" do
      schema_path = Rails.root.join('app/lib/three_scale/swagger/schemas/swagger-1.2.schema.json')

      assert File.exist?(schema_path), "Monolithic Swagger 1.2 schema should exist"

      schema = JSON.parse(File.read(schema_path))

      # Should have definitions inlined (not external refs)
      assert schema.key?("definitions"), "Should have definitions section"
      assert schema["definitions"].key?("modelsObject"), "Should have modelsObject definition inlined"
      assert schema["definitions"].key?("authorizationObject"), "Should have authorizationObject definition inlined"
    end

    test "Echo API validates correctly" do
      specification = fixture_spec('echo-api-1.2')

      assert specification.valid?, "Echo API Swagger 1.2 should be valid"
      assert_equal "1.2", specification.swagger_version
    end
  end

  class V20Test < ActiveSupport::TestCase
    include FixtureHelper

    test "valid swagger 2.0 spec" do
      specification = fixture_spec('pet-store-2.0')
      assert specification.valid?, 'specification should be valid'
      assert_equal "2.0", specification.swagger_version
    end

    test "invalid swagger 2.0 spec errors" do
      specification = fixture_spec('invalid-2.0')
      assert_not specification.valid?
      errors = specification.errors.full_messages_for(:base)
      assert_equal 4, errors.size, "Should have exactly 4 validation errors"
      # json_schemer error messages
      assert errors.include?("object property at `/invalid` is a disallowed additional property"), "Should error on invalid property"
      assert errors.include?("object property at `/another` is a disallowed additional property"), "Should error on another property"
      assert errors.include?("object at `/info` is missing required properties: title"), "Should error on missing title"
      assert errors.include?("object property at `/info/foo` is a disallowed additional property"), "Should error on foo property"
    end

    test "base path extraction" do
      specification = ThreeScale::Swagger::Specification.new({schemes: ["ftp", "https"], host: "google.com", swagger: "2.0"}.to_json)
      assert_equal "ftp://google.com", specification.base_path

      specification = ThreeScale::Swagger::Specification.new({swagger: "2.0"}.to_json)
      assert_equal "", specification.base_path
    end

    test "json_schema is memoized at class level" do
      # First call should parse the schema
      schema1 = ThreeScale::Swagger::Specification::V20.json_schema

      # Second call should return the same object (not re-parse)
      schema2 = ThreeScale::Swagger::Specification::V20.json_schema

      assert_same schema1, schema2, "Schema should be memoized at class level"
      assert schema1.frozen?, "Schema should be frozen"
    end

    test "Echo API validates correctly" do
      specification = fixture_spec('echo-api-2.0')

      assert specification.valid?, "Echo API Swagger 2.0 should be valid"
      assert_equal "2.0", specification.swagger_version
    end
  end

  class V30Test < ActiveSupport::TestCase
    include FixtureHelper

    test 'valid openapi 3.0 spec' do
      specification = fixture_spec('pet-store-3.0')
      assert_valid specification
      assert_equal "3.0", specification.swagger_version
    end

    test "invalid openapi 3.0 spec errors" do
      specification = fixture_spec('invalid-3.0')
      assert_not specification.valid?
      errors = specification.errors.full_messages_for(:base).join(', ')
      assert errors.include? "object property at `/invalid` is a disallowed additional property"
      assert errors.include? "object property at `/another` is a disallowed additional property"
      assert errors.include? "object at `/info` is missing required properties: title"
      assert errors.include? "object property at `/info/foo` is a disallowed additional property"
    end

    test 'base path extraction' do
      specification = ThreeScale::Swagger::Specification.new({ openapi: '3.0.0', servers: [{ url: 'https://my-petstore.io' }] }.to_json)
      assert_equal 'https://my-petstore.io', specification.base_path

      specification = ThreeScale::Swagger::Specification.new({ openapi: '3.0.0' }.to_json)
      assert_nil specification.base_path
    end
  end

  class V31Test < ActiveSupport::TestCase
    include FixtureHelper

    test 'valid openapi 3.1 spec' do
      specification = fixture_spec('pet-store-3.1')
      assert specification.valid?, 'specification should be valid'
      assert_valid specification
      assert_equal "3.1", specification.swagger_version
    end

    test "invalid openapi 3.1 spec errors" do
      specification = fixture_spec('invalid-3.1')
      assert_not specification.valid?
      errors = specification.errors.full_messages_for(:base).join(', ')
      assert errors.include? "object property at `/invalid` is a disallowed unevaluated property"
      assert errors.include? "object property at `/another` is a disallowed unevaluated property"
      assert errors.include? "object at `/info` is missing required properties: title"
      assert errors.include? "object property at `/info/foo` is a disallowed unevaluated property"
    end

    test 'base path extraction' do
      specification = ThreeScale::Swagger::Specification.new({ openapi: '3.1.0', servers: [{ url: 'https://my-petstore.io' }] }.to_json)
      assert_equal 'https://my-petstore.io', specification.base_path

      specification = ThreeScale::Swagger::Specification.new({ openapi: '3.1.0' }.to_json)
      assert_nil specification.base_path
    end
  end

  class SwaggerTest < ActiveSupport::TestCase
    test "V20 and V12 have separate memoized schemas" do
      schema_v20 = ThreeScale::Swagger::Specification::V20.json_schema
      schema_v12 = ThreeScale::Swagger::Specification::V12.json_schema

      assert_not_same schema_v20, schema_v12, "V20 and V12 should have separate cached schemas"
    end

    test "DRAFT4_RESOLVER resolves Draft 4 URI" do
      draft4_uri = JSONSchemer::Draft4::BASE_URI.dup.tap { |uri| uri.fragment = nil }

      result = ThreeScale::Swagger::Specification::Swagger::DRAFT4_RESOLVER.call(draft4_uri)

      assert_equal JSONSchemer::Draft4::SCHEMA, result
      assert_kind_of Hash, result, "Should return Draft 4 schema as Hash"
    end

    test "DRAFT4_RESOLVER returns nil for unknown URIs" do
      unknown_uri = URI("http://example.com/unknown-schema")

      result = ThreeScale::Swagger::Specification::Swagger::DRAFT4_RESOLVER.call(unknown_uri)

      assert_nil result, "Should return nil for unknown URIs"
    end
  end

  class GeneralTest < ActiveSupport::TestCase
    test "invalid JSON specification" do
      specification = ThreeScale::Swagger::Specification.new('invalid json')

      assert_not specification.valid?, 'specification should not be valid'
      assert_not specification.base_path, 'should not have base path'
      assert_not specification.swagger?, 'should not be swagger'
    end

    test "array instead of object specification" do
      specification = ThreeScale::Swagger::Specification.new('[{"PQ Entity Status": "Pending"}]')

      assert_not specification.valid?, 'specification should not be valid'
      assert_not specification.base_path, 'should not have base path'
      assert_not specification.swagger?, 'should not be swagger'
    end
  end

  class AutocompleteTest < ActiveSupport::TestCase
    test "add x-data-threescale-name if threescale_name exists" do
      specification = ThreeScale::Swagger::Specification.new({parameters: {threescale_name: :bar}}.to_json).as_json
      assert_equal "bar", specification["parameters"]["x-data-threescale-name"]
    end
  end

  class SchemesTest < ActiveSupport::TestCase
    test 'add schemes if not present for Swagger 1.2' do
      spec = { swaggerVersion: '1.2'}
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_equal ["http"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ basePath: 'https://example.net'}).to_json).as_json
      assert_equal ["https"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ schemes: ['foo'] }).to_json).as_json
      assert_equal ["foo"], specification["schemes"]
    end

    test 'add schemes if not present for Swagger 2.0' do
      spec = { swagger: '2.0'}
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_equal ["http"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ basePath: 'https://example.net'}).to_json).as_json
      assert_equal ["https"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ schemes: ['foo'] }).to_json).as_json
      assert_equal ["foo"], specification["schemes"]
    end

    test 'do not add schemes for OpenAPI 3.0' do
      spec = { openapi: '3.0.0' }
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI 3.0.0"

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ servers: ['https://example.net'] }).to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI 3.0.0"
    end

    test 'do not add schemes for OpenAPI 3.1' do
      spec = { openapi: '3.1.0' }
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI 3.1.0"

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ servers: ['https://example.net'] }).to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI 3.1.0"
    end
  end
end
