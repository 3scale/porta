# frozen_string_literal: true

module ThreeScale
  class Settings
    include Singleton

    attr_reader :config

    class << self
      delegate :configure, :merge!, :get, :key?, to: :instance
    end

    delegate :key?, to: :config

    def initialize
      @config = ActiveSupport::Configurable::Configuration.new
      super
    end

    def configure(key, &processor)
      config[key] = processor.call
    end

    def merge!(hash)
      config.merge! hash.symbolize_keys
    end

    def get(key)
      config.fetch key.to_sym
    end
  end
end
