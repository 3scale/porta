# frozen_string_literal: true

require 'test_helper'

class Features::AccountDeletionConfigTest < ActiveSupport::TestCase
  def setup
    @valid_config = {'enabled' => true, 'account_suspension' => 30, 'account_inactivity' => 50, 'contract_unpaid_time' => 70, 'disabled_for_app_plans' => %w[foo bar]}
  end

  attr_reader :valid_config

  test 'loads and fetches all the values' do
    valid_config.each { |key, value| assert_equal value, account_deletion_config.config.public_send(key) }
    assert account_deletion_config.enabled?
  end

  test 'it is not enabled if the config is not provided or if enabled is false' do
    refute account_deletion_config('').enabled?
    refute account_deletion_config(valid_config.merge('enabled' => false)).enabled?
  end

  private

  def account_deletion_config(config = valid_config)
    Features::AccountDeletionConfig.new(config)
  end
end
