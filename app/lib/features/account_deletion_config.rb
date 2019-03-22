# frozen_string_literal: true

module Features
  class AccountDeletionConfig
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
      config = (config || {}).each_with_object({}) do |(key, value), collection|
        collection[key.to_sym] = value if value.is_a?(Integer)
      end
      @config = ActiveSupport::OrderedOptions.new.merge(config)
    end

    def check_validity(initial_config)
      @valid = %i[account_suspension account_inactivity contract_unpaid_time].all? { |key| config.key?(key) }
      return if valid || initial_config.blank?
      Rails.logger.warn '[WARNING] Can\'t enable "automatic inactive tenant account deletion". Please revise your config"'
    end
  end
end
