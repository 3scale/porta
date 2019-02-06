# frozen_string_literal: true

module AccountDeletionConfig
  module_function

  def config
    @config ||= load_config
  end

  def valid?
    instance_variable_defined?(:@valid) ? @valid : (@valid = check_validity)
  end

  def load_config
    config = ThreeScale.config.ttl.account_deletion.each_with_object({}) do |(key, value), collection|
      collection[key.to_sym] = value if value.is_a?(Integer)
    end
    ActiveSupport::OrderedOptions.new.merge(config)
  end

  def check_validity
    valid = %i[account_suspension account_inactivity contract_unpaid_time].all? { |key| config.key?(key) }
    return valid if valid || ThreeScale.config.ttl.account_deletion.blank?
    Rails.logger.warn '[WARNING] Can\'t enable "automatic inactive tenant account deletion". Please revise your config"'
    valid
  end
end
