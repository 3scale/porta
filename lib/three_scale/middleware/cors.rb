# frozen_string_literal: true

module ThreeScale::Middleware
  class Cors < Rack::Cors
    def initialize(app, opts = {}, &block)
      origins = config.origins.presence || '*'
      resources = config.resources.presence || '*'

      super(app, opts) do
        allow do
          self.origins origins
          [*resources].each do |resource|
            self.resource resource, headers: :any, methods: [:get, :post, :patch, :put, :delete]
          end
        end
      end

      if block_given?
        if block.arity == 1
          block.call(self)
        else
          instance_eval(&block)
        end
      end
    end

    def call(env)
      return @app.call(env) unless enabled?
      super
    end

    def config
      Rails.configuration.three_scale.cors
    end

    delegate :enabled, to: :config
    alias enabled? enabled
  end
end
