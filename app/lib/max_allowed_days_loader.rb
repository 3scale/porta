# frozen_string_literal: true

module MaxAllowedDaysLoader
  module_function

  def load_account_suspension
    config[:account_suspension]
  end

  def load_account_inactivity
    config[:account_inactivity]
  end

  def load_contract_unpaid_time
    config[:contract_unpaid_time]
  end

  def config
    @config ||= load_config
  end

  def valid_configuration?
    config && @valid_configuration
  end

  def load_config
    config = (ThreeScale.config.max_allowed_days || {}).each_with_object({}) do |(key, value), collection|
      collection[key.to_sym] = value.public_send(:days) if value.to_i >= 1
    end
    @valid_configuration = %i[account_suspension account_inactivity contract_unpaid_time].all? { |key| config.key?(key) }
    inform_invalid_configuration unless @valid_configuration
    config
  end

  def inform_invalid_configuration
    Rails.logger.warn %q(
The feature "automatically suspend inactivy tenants and automatically schedule them for deletion" is disabled.
To enable it, please provide the number of days for 'account_suspension', 'account_inactivity' and 'contract_unpaid_time'.
All of them must be numbers and their value must be minimum 1 for all of them.
)
  end
end
