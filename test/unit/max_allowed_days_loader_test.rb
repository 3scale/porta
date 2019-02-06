# frozen_string_literal: true

require 'test_helper'

class MaxAllowedDaysLoaderTest < ActiveSupport::TestCase
  def setup
    MaxAllowedDaysLoader.instance_variable_set(:@config, nil)
    MaxAllowedDaysLoader.instance_variable_set(:@valid, nil)
    @valid_config = {'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70}
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    ThreeScale.config.stubs(:max_allowed_days).returns(valid_config)
    valid_config.each { |key, value| assert_equal value, MaxAllowedDaysLoader.config.public_send(key) }
    assert MaxAllowedDaysLoader.valid?
  end

  test 'marks as invalid if any value is not an integer' do
    ThreeScale.config.stubs(:max_allowed_days).returns(ThreeScale.config.stubs(:max_allowed_days).returns(valid_config.merge({'account_suspension' => 'foo'})))
    refute MaxAllowedDaysLoader.valid?
  end

  test 'marks as invalid if any value is missing' do
    valid_config.delete('account_suspension')
    ThreeScale.config.stubs(:max_allowed_days).returns(ThreeScale.config.stubs(:max_allowed_days).returns(valid_config))
    refute MaxAllowedDaysLoader.valid?
  end
end
