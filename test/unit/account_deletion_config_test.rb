# frozen_string_literal: true

require 'test_helper'

class AccountDeletionConfigTest < ActiveSupport::TestCase
  def setup
    @valid_config = {'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70}
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    valid_config.each { |key, value| assert_equal value, account_deletion_config.config.public_send(key) }
    assert account_deletion_config.valid?
  end

  test 'marks as invalid if any value is not an integer' do
    valid_config['account_suspension'] = 'foo'
    refute account_deletion_config.valid?
  end

  test 'marks as invalid if any value is missing' do
    valid_config.delete('account_suspension')
    refute account_deletion_config.valid?
  end

  private

  def account_deletion_config
    AccountDeletionConfig.new(valid_config)
  end
end
