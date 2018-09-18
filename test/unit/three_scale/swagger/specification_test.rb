require "test_helper"

class ThreeScale::Swagger::SpecificationTest < ActiveSupport::TestCase

  test "pet store swagger 1.2" do
    doc = load_fixture "pet-resource-1.2"
    specification = ThreeScale::Swagger::Specification.new doc

    assert specification.valid?, 'specification should be valid'
  end

  test "petstore swagger 2.0" do
    doc= load_fixture "pet-store-2.0"
    specification = ThreeScale::Swagger::Specification.new(doc)

    assert specification.valid?, 'specification should be valid'
  end

  test "swagger 2.0 base path" do
    specification = ThreeScale::Swagger::Specification.new({schemes: ["ftp", "https"], host: "google.com", swagger: "2.0"}.to_json)
    assert "ftp://google.com", specification.base_path

    specification = ThreeScale::Swagger::Specification.new({swagger: "2.0"}.to_json)
    assert "", specification.base_path
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

  test 'add schemes if is not present' do
    specification = ThreeScale::Swagger::Specification.new({}.to_json).as_json
    assert_equal ["http"], specification["schemes"]

    specification = ThreeScale::Swagger::Specification.new({"basePath" => "https://example.net"}.to_json).as_json
    assert_equal ["https"], specification["schemes"]

    specification = ThreeScale::Swagger::Specification.new({schemes: ["foo"]}.to_json).as_json
    assert_equal ["foo"], specification["schemes"]
  end

  private


    def load_fixture file
      File.read Rails.root.join "test", "fixtures", "swagger", "#{file}.json"
    end

    def i18n_error error
      I18n.backend.translate I18n.locale, "activerecord.errors.models.api_docs/service.attributes.body.#{error}" unless error.nil?
    end
end
