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
    refute specification.valid?, 'specification should not be valid'
    assert_includes specification.errors[:base], 'The property \'#/\' did not contain a required property of \'name\' in schema http://apicast.io/policy-v1/schema#'
  end
end
