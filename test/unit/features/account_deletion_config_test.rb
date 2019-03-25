# frozen_string_literal: true

require 'test_helper'

class Features::AccountDeletionConfigTest < ActiveSupport::TestCase
  def setup
    @valid_config = {'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70, 'disabled_for_app_plans' => %w[foo bar]}
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    valid_config.each { |key, value| assert_equal value, account_deletion_config.config.public_send(key) }
    assert account_deletion_config.valid?
  end

  test 'marks as invalid if any value of the expected integers is not an integer' do
    integer_values = %w[account_suspension account_inactivity contract_unpaid_time]
    valid_config.slice(*integer_values).each_key do |k|
      config = valid_config.dup
      config[k] = 'foo'
      refute account_deletion_config(config).valid?
    end
  end

  test 'marks as invalid if the disabled_for_app_plans is not an array' do
    config = valid_config.dup
    config['disabled_for_app_plans'] = 1
    refute account_deletion_config(config).valid?
  end

  test 'marks as invalid if any value is missing' do
    valid_config.each_key do |k|
      config = valid_config.dup
      config.delete(k)
      refute account_deletion_config(config).valid?
    end
  end

  private

  def account_deletion_config(config = valid_config)
    Features::AccountDeletionConfig.new(config)
  end
end
