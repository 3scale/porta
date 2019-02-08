# frozen_string_literal: true

require 'test_helper'

class AccountDeletionConfigTest < ActiveSupport::TestCase
  def setup
    %i[@config @valid].each { |variable| AccountDeletionConfig.remove_instance_variable(variable) if AccountDeletionConfig.instance_variable_defined?(variable) }
    @valid_config = {'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70}
  end

  def teardown
    %i[@config @valid].each { |variable| AccountDeletionConfig.remove_instance_variable(variable) if AccountDeletionConfig.instance_variable_defined?(variable) }
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    ThreeScale.config.features.stubs(:account_deletion).returns(valid_config)
    valid_config.each { |key, value| assert_equal value, AccountDeletionConfig.config.public_send(key) }
    assert AccountDeletionConfig.valid?
  end

  test 'marks as invalid if any value is not an integer' do
    ThreeScale.config.features.stubs(:account_deletion).returns(valid_config.merge({'account_suspension' => 'foo'}))
    refute AccountDeletionConfig.valid?
  end

  test 'marks as invalid if any value is missing' do
    valid_config.delete('account_suspension')
    ThreeScale.config.features.stubs(:account_deletion).returns(valid_config)
    refute AccountDeletionConfig.valid?
  end
end
