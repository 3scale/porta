# frozen_string_literal: true

module Features
  class Config
    def self.configure(config = {})
      @configuration = new(config)
    end

    def self.configuration
      (@configuration || configure)
    end

    def self.config
      configuration.config
    end

    def self.enabled?
      configuration.enabled?
    end

    def initialize(config = {})
      @config = ActiveSupport::OrderedOptions.new.merge((config.presence || {}).symbolize_keys)
    end

    attr_reader :config

    def enabled?
      config[:enabled]
    end
  end
end
