require 'test_helper'

class ThreeScale::Swagger::AutocompleteTest < ActiveSupport::TestCase

  test 'fix! do not raise error for an array and return the same object' do
    assert_equal [1,2,3], ThreeScale::Swagger::Autocomplete.fix!([1,2,3])
  end

  test 'fix! search for parameters > threescale_name and copy the value to x-data-threescale-name' do
    spec = ThreeScale::Swagger::Autocomplete.fix!(JSON.parse(minimal_swagger_spec))

    scope_operations = spec['apis'][0]['operations']
    scope_params     = scope_operations[0]['parameters']

    assert_equal 'foo', scope_params[0]['x-data-threescale-name']
    assert_equal 'bar', scope_params[1]['x-data-threescale-name']

    scope_operations = spec['apis'][1]['operations']
    scope_params     = scope_operations[0]['parameters']

    assert_equal 'foobar', scope_params[0]['x-data-threescale-name']
  end

  test 'fix! threescale_name attribute might not exists' do

    spec = ThreeScale::Swagger::Autocomplete.fix!(JSON.parse(incompletely_swagger_spec_json))

    scope_operations = spec['apis'][0]['operations']

    assert_equal [], scope_operations[0]['parameters']
  end

  private

  def incompletely_swagger_spec_json
    {
      apis: [
        {
          operations: [
            {
              parameters: []
            }
          ]
        }
      ]
    }.to_json
  end

  def minimal_swagger_spec
    {
      apis: [
        {
          operations: [
            {
              parameters: [
                {
                  threescale_name: 'foo'
                },
                {
                  threescale_name: 'bar'
                }
              ]
            }
          ]
        },
        {
          operations: [
            {
              parameters: [
                {
                  threescale_name: 'foobar'
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end
end
