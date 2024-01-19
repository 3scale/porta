# frozen_string_literal: true

module ThreeScale
  module Middleware

    class Multitenant
      def self.log(message)
        Rails.logger.debug "[MultiTenant] #{message}" if ENV['DEBUG']
      end

      class TenantChecker
        attr_reader :original, :attribute

        class TenantLeak < StandardError
          def initialize(object, attribute, original)
            @object = object
            @attribute = attribute
            @original = original
          end

          def to_s
            "#{@object.class}:#{@object.id} has #{@attribute} #{@object.send(@attribute).inspect} but #{@original.inspect} already exists."
          end
        end

        def initialize(attribute, app, env)
          @original = nil
          @attribute = attribute
          @app = app
          @env = env
        end

        def verify!(object)

          # this controller shouldn't be checked
          return true if @env["action_dispatch.request.path_parameters"]["controller"] == "provider/domains"

          # when the ActiveRecord object doesn't have tenant_id attribute at all
          unless object.respond_to?(attribute)
            # Multitenant.log "#{object} does not respond to: #{attribute}"
            return true
          end

          # reload object if it was partially loaded from db without the `tenant_id` attribute
          begin
            current = object.send(attribute)
          rescue ActiveRecord::MissingAttributeError
            # Multitenant.log("#{object} is missing #{attribute}. Reloading and trying again")
            fresh = object.class.unscoped.find(object.id, :select => attribute)
            current = fresh.send(attribute)
          end

          # this is when tenant_id is not set because of a bug or in older installations the master account has it nil
          return if current.nil?

          # in newer installations master account has a tenant_id same as its id, like other providers
          return if object.is_a?(::Account) && object.master

          # once initialized a legitimate AR object with a tenant_id, all others in the request should have the same
          @original ||= current

          return if current == original

          # we still need to check if it wasn't master before raising a tenant leak
          @master ||= ::Account.unscoped.master

          # this is supposed to match how we get the user_session in app/lib/authenticated_system/request.rb
          # on API calls cookies are not present though, so we need to use safe navigation
          @user_session ||= UserSession.authenticate(@env['action_dispatch.cookies']&.signed&.public_send(:[], :user_session))
          return if @user_session&.user&.account == @master

          return if @env["action_dispatch.request.query_parameters"]["provider_key"] == @master.api_key

          # must match how we check access token in app/lib/api_authentication/by_access_token.rb
          return if @master.access_tokens.find_from_value(@env["action_dispatch.request.query_parameters"]["access_token"])

          raise TenantLeak.new(object, attribute, original)
        end
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
