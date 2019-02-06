# frozen_string_literal: true

module AccountSuspensionConfig
  module_function

  def config
    @config ||= load_config
  end

  def valid?
    @valid ||= check_validity
  end

  def load_config
    config = ThreeScale.config.max_allowed_days.each_with_object({}) do |(key, value), collection|
      collection[key.to_sym] = value if value.is_a?(Integer)
    end
    ActiveSupport::OrderedOptions.new.merge(config)
  end

  def check_validity
    valid = %i[account_suspension account_inactivity contract_unpaid_time].all? { |key| config.key?(key) }
    inform_invalid_configuration if !valid && ThreeScale.config.max_allowed_days.present?
    valid
  end

  def inform_invalid_configuration
    Rails.logger.warn '[WARNING] Can\'t enable "automatic inactive tenant account deletion". Please revise your config"'
  end
end
