# frozen_string_literal: true

module Features
  class AccountDeletionConfig
    EXPECTED_VALUES = {
      account_suspension: Integer, account_inactivity: Integer, contract_unpaid_time: Integer,
      disabled_for_app_plans: Array
    }.freeze

    def self.configure(config = {})
      @configuration = new(config)
    end

    def self.configuration
      (@configuration || configure)
    end

    def self.config
      configuration.config
    end

    def self.valid?
      configuration.valid?
    end

    def initialize(config = {})
      format_config(config)
      check_validity(config)
    end

    attr_reader :config, :valid
    alias valid? valid

    private

    def format_config(config)
      config = (config || {}).symbolize_keys.slice(*EXPECTED_VALUES.keys).each_with_object({}) do |(key, value), collection|
        collection[key] = value if value.is_a?(EXPECTED_VALUES[key])
      end
      @config = ActiveSupport::OrderedOptions.new.merge(config)
    end

    def check_validity(initial_config)
      @valid = (EXPECTED_VALUES.keys.length == config.length)
      return if valid || initial_config.blank?
      Rails.logger.warn '[WARNING] Can\'t enable "automatic inactive tenant account deletion". Please revise your config"'
    end
  end
end
