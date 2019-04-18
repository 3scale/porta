# frozen_string_literal: true

module Features
  class FeatureBase
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

    def initialize(*)
      raise NoMethodError, "#{__method__} not implemented in #{self.class}"
    end

    def config
      raise NoMethodError, "#{__method__} not implemented in #{self.class}"
    end

    def enabled?
      config[:enabled]
    end
  end
end
