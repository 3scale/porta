# frozen_string_literal: true

module ThreeScale::Middleware
  class Cors < Rack::Cors
    def initialize(app, opts = {}, &block)
      super(app, opts) { set_config }

      if block_given?
        if block.arity == 1
          block.call(self)
        else
          instance_eval(&block)
        end
      end
    end

    def call(env)
      return @app.call(env) if disabled? || signup_controller?(env)

      super
    end

    def config
      Rails.configuration.three_scale.cors
    end

    delegate :enabled, to: :config
    alias enabled? enabled

    def disabled?
      !enabled?
    end

    private

    def set_config
      rules = config.allow.presence || []

      rules.map(&:symbolize_keys).each do |rule|
        origins = rule[:origins].presence || '*'
        resources = rule[:resources].presence || '*'
        methods = rule[:methods].presence || :get

        allow do
          self.origins origins
          [*resources].each do |resource|
            self.resource resource, headers: rule[:headers].presence, methods: methods, credentials: rule[:credentials].present?, max_age: rule[:max_age].presence, vary: rule[:vary], expose: rule[:expose].presence
          end
        end
      end
    end

    def signup_controller?(env)
      evaluate_path(env).start_with? '/p/signup'
    end
  end
end
