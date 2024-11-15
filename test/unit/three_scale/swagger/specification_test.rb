# frozen_string_literal: true

require "test_helper"

class ThreeScale::Swagger::SpecificationTest < ActiveSupport::TestCase
  test "pet store swagger 1.2" do
    specification = fixture_spec('pet-resource-1.2')
    assert specification.valid?, 'specification should be valid'
  end

  test "petstore swagger 2.0" do
    specification = fixture_spec('pet-store-2.0')
    assert specification.valid?, 'specification should be valid'
  end

  test "invalid 2.0 spec errors" do
    specification = fixture_spec('invalid-2.0')
    assert_not specification.valid?
    errors = specification.errors.full_messages_for(:base).join(', ')
    assert errors.include? "The property '#/' contains additional properties [\"invalid\", \"another\"] outside of the schema when none are allowed"
    assert errors.include? "The property '#/info' did not contain a required property of 'title'"
    assert errors.include? "The property '#/info' contains additional properties [\"foo\"] outside of the schema when none are allowed"
    assert_equal 3, errors.scan(%r{http://swagger.io/v2/schema.json#}).count
  end

  test "swagger 2.0 base path" do
    specification = ThreeScale::Swagger::Specification.new({schemes: ["ftp", "https"], host: "google.com", swagger: "2.0"}.to_json)
    assert "ftp://google.com", specification.base_path

    specification = ThreeScale::Swagger::Specification.new({swagger: "2.0"}.to_json)
    assert "", specification.base_path
  end

  test 'petstore oas 3.0' do
    specification = fixture_spec('pet-store-3.0')
    assert_valid specification
  end

  test 'petstore oas 3.1' do
    specification = fixture_spec('pet-store-3.1')
    assert specification.valid?, 'specification should be valid'
    assert_valid specification
  end

  test "invalid 3.0 spec errors" do
    specification = fixture_spec('invalid-3.0')
    assert_not specification.valid?
    errors = specification.errors.full_messages_for(:base).join(', ')
    assert errors.include? "object property at `/invalid` is a disallowed additional property"
    assert errors.include? "object property at `/another` is a disallowed additional property"
    assert errors.include? "object at `/info` is missing required properties: title"
    assert errors.include? "object property at `/info/foo` is a disallowed additional property"
  end

  test "invalid 3.1 spec errors" do
    specification = fixture_spec('invalid-3.1')
    assert_not specification.valid?
    errors = specification.errors.full_messages_for(:base).join(', ')
    assert errors.include? "object property at `/invalid` is a disallowed unevaluated property"
    assert errors.include? "object property at `/another` is a disallowed unevaluated property"
    assert errors.include? "object at `/info` is missing required properties: title"
    assert errors.include? "object property at `/info/foo` is a disallowed unevaluated property"
  end

  test 'oas 3.x base path' do
    %w[3.0.0 3.1.0].each do |version|
      specification = ThreeScale::Swagger::Specification.new({ openapi: version, servers: [{ url: 'https://my-petstore.io' }] }.to_json)
      assert_equal 'https://my-petstore.io', specification.base_path

      specification = ThreeScale::Swagger::Specification.new({ openapi: version }.to_json)
      assert_nil specification.base_path
    end
  end

  test "invalid specification" do
    specification = ThreeScale::Swagger::Specification.new('invalid json')

    assert_not specification.valid?, 'specification should not be valid'
    assert_not specification.base_path, 'should not have base path'
    assert_not specification.swagger?, 'should not be swagger'

    specification = ThreeScale::Swagger::Specification.new('[{"PQ Entity Status": "Pending"}]')

    assert_not specification.valid?, 'specification should not be valid'
    assert_not specification.base_path, 'should not have base path'
    assert_not specification.swagger?, 'should not be swagger'
  end

  test "add x-data-threescale-name if threescale_name exists" do
    specification = ThreeScale::Swagger::Specification.new({parameters: {threescale_name: :bar}}.to_json).as_json
    assert_equal "bar", specification["parameters"]["x-data-threescale-name"]
  end

  test 'add schemes if is not present for Swagger v1 and v2' do
    [{ swaggerVersion: '1.2'}, { swagger: '2.0'}].each do |spec|
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_equal ["http"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ basePath: 'https://example.net'}).to_json).as_json
      assert_equal ["https"], specification["schemes"]

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ schemes: ['foo'] }).to_json).as_json
      assert_equal ["foo"], specification["schemes"]
    end
  end

  test 'do not add schemes for OpenAPI v3' do
    %w[3.0.0 3.1.0].each do |version|
      spec = { openapi: version }
      specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI #{version}"

      specification = ThreeScale::Swagger::Specification.new(spec.merge({ servers: ['https://example.net'] }).to_json).as_json
      assert_nil specification["schemes"], "'schemes' is present for OpenAPI #{version}"
    end
  end

  private

  def fixture_spec(fixture_file_name)
    ThreeScale::Swagger::Specification.new(file_fixture("swagger/#{fixture_file_name}.json").read)
  end
end
