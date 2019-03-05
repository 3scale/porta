# frozen_string_literal: true

require 'test_helper'

class PermittedParams::PolicyParamsTest < ActiveSupport::TestCase

  test '#to_params is permitted' do
    assert PermittedParams::PolicyParams.new.to_params.permitted?
  end

  test 'Only keeps name, version and schema' do
    params = PermittedParams::PolicyParams.new(name: 'hello', version: '1.0', account: Account.new, schema: 'schema')
    assert_equal({name: 'hello', version: '1.0', schema: 'schema'}.stringify_keys, params.to_params)
  end

  test 'schema is ommitted' do
    params = PermittedParams::PolicyParams.new(name: 'hello', version: '1.0')
    assert_equal({name: 'hello', version: '1.0', schema: nil}.stringify_keys, params.to_params)
  end

  test 'schema is a Hash' do
    params = PermittedParams::PolicyParams.new(schema: {foo: :bar})
    assert_equal({schema: {foo: :bar} }.deep_stringify_keys, params.to_params)
  end
end

