# frozen_string_literal: true

require 'test_helper'

class MaxAllowedDaysLoaderTest < ActiveSupport::TestCase
  def setup
    MaxAllowedDaysLoader.instance_variable_set(:@config, nil)
    MaxAllowedDaysLoader.instance_variable_set(:@valid_configuration, nil)
  end

  test 'loads and fetches all the values' do
    config = {'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70}
    ThreeScale.config.stubs(:max_allowed_days).returns(config)
    config.each { |key, value| assert_equal value.public_send(:days), MaxAllowedDaysLoader.public_send("load_#{key}") }
    assert MaxAllowedDaysLoader.valid_configuration?
  end

  test 'filters invalid values and marks it as invalid' do
    %i[account_suspension account_inactivity contract_unpaid_time].each do |key|
      [-10, 0.1, 'foo', nil].each do |invalid_value|
        MaxAllowedDaysLoader.instance_variable_set(:@config, nil)
        MaxAllowedDaysLoader.instance_variable_set(:@valid_configuration, nil)
        ThreeScale.config.stubs(:max_allowed_days).returns(ThreeScale.config.stubs(:max_allowed_days).returns({key => invalid_value}))
        assert_nil MaxAllowedDaysLoader.public_send("load_#{key}")
        refute MaxAllowedDaysLoader.valid_configuration?
      end
    end
  end
end
