# frozen_string_literal: true

require 'test_helper'

class CurrenciesLoaderTest < ActiveSupport::TestCase
  test 'default when no yaml or empty' do
    ThreeScale.config.stubs(:currencies).returns({})

    expected_default = { 'USD - American Dollar' => 'USD', 'EUR - Euro' => 'EUR' }

    assert_equal expected_default, CurrenciesLoader.load_config
  end

  test 'load from non-empty config' do
    custom_config = {
      'CNY - Chinese Yuan Renminbi' => 'CNY',
      'CAD - Canadian Dollar' => 'CAD',
      'AUD - Australian Dollar' => 'AUD',
      'JPY - Japanese Yen' => 'JPY',
      'CHF - Swiss Franc' => 'CHF',
      'SAR - Saudi Riyal' => 'SAR'
    }
    ThreeScale.config.stubs(:currencies).returns(custom_config)

    expected_config = {
      'USD - American Dollar' => 'USD',
      'EUR - Euro' => 'EUR'
    }.merge(custom_config)

    assert_equal expected_config, CurrenciesLoader.load_config
  end
end
