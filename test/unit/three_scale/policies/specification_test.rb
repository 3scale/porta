# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Policies::SpecificationTest < ActiveSupport::TestCase

  test '#valid? returns true when the schema is valid' do
    doc = JSON.parse(file_fixture('policies/apicast-policy.json').read)
    specification = ThreeScale::Policies::Specification.new(doc)
    assert specification.valid?, 'specification should be valid'
  end

  test 'valid? returns false for an invalid specification and errors returns why' do
    specification = ThreeScale::Policies::Specification.new({"foo" => "bar"})
    assert_not specification.valid?, 'specification should not be valid'
    assert_includes specification.errors[:base], "object at root is missing required properties: name, version, configuration, summary"
  end

  test "use the default policy schema if the document doesn't include the schema ID" do
    doc = JSON.parse(file_fixture('policies/apicast-policy.json').read)
    doc.delete("$schema")

    specification = ThreeScale::Policies::Specification.new(doc)
    assert specification.valid?, 'specification should be valid'
  end

  test "unsupported schema" do
    doc = JSON.parse(file_fixture('policies/apicast-policy.json').read)
    doc["$schema"] = "invalid"

    specification = ThreeScale::Policies::Specification.new(doc)
    assert_not specification.valid?, 'specification should not be valid'
    assert_includes specification.errors[:base], "unsupported schema"
  end

  test "support policies with #manifest in schema ID" do
    doc = JSON.parse(file_fixture('policies/apicast-policy.json').read)
    doc["$schema"] = "http://apicast.io/policy-v1/schema#manifest#"

    specification = ThreeScale::Policies::Specification.new(doc)
    assert specification.valid?, 'specification should be valid'
  end
end
