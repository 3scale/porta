# frozen_string_literal: true

module ThreeScale
  module Middleware

    class Multitenant
      def self.log(message)
        Rails.logger.debug "[MultiTenant] #{message}" if ENV['DEBUG']
      end

      module EnforceTenant
        extend ActiveSupport::Concern

        included do
          after_initialize :enforce_tenant!
        end

        private

        def enforce_tenant!
          # Multitenant.log "initialized object #{self.class}:#{self.id}"
          Thread.current[:multitenant]&.verify!(self)
        end
      end

      def initialize(app, attribute)
        @app = app
        @attribute = attribute
        ActiveRecord::Base.send(:include, EnforceTenant)
      end

      def call(env)
        dup._call(env)
      end

      def _call(env)
        Thread.current[:multitenant] = TenantChecker.new(@attribute,@app,env)
        @app.call(env)
      ensure
        Thread.current[:multitenant] = nil
      end
    end
  end
end
