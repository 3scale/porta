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

  test "swagger 2.0 base path" do
    specification = ThreeScale::Swagger::Specification.new({schemes: ["ftp", "https"], host: "google.com", swagger: "2.0"}.to_json)
    assert "ftp://google.com", specification.base_path

    specification = ThreeScale::Swagger::Specification.new({swagger: "2.0"}.to_json)
    assert "", specification.base_path
  end

  test 'petstore oas 3.0' do
    specification = fixture_spec('pet-store-3.0')
    assert specification.valid?, 'specification should be valid'
  end

  test 'oas 3.0 base path' do
    specification = ThreeScale::Swagger::Specification.new({ openapi: '3.0.0', servers: [{ url: 'https://my-petstore.io' }] }.to_json)
    assert_equal 'https://my-petstore.io', specification.base_path

    specification = ThreeScale::Swagger::Specification.new({ openapi: '3.0.0' }.to_json)
    refute specification.base_path
  end

  test "invalid specification" do
    specification = ThreeScale::Swagger::Specification.new('invalid json')

    refute specification.valid?, 'specification should not be valid'
    refute specification.base_path, 'should not have base path'
    refute specification.swagger?, 'should not be swagger'

    specification = ThreeScale::Swagger::Specification.new('[{"PQ Entity Status": "Pending"}]')

    refute specification.valid?, 'specification should not be valid'
    refute specification.base_path, 'should not have base path'
    refute specification.swagger?, 'should not be swagger'
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
    spec = { openapi: '3.0.0' }
    specification = ThreeScale::Swagger::Specification.new(spec.to_json).as_json
    assert_nil specification["schemes"]

    specification = ThreeScale::Swagger::Specification.new(spec.merge({ servers: ['https://example.net'] }).to_json).as_json
    assert_nil specification["schemes"]
  end

  private

  def fixture_spec(fixture_file_name)
    ThreeScale::Swagger::Specification.new(file_fixture("swagger/#{fixture_file_name}.json").read)
  end
end
