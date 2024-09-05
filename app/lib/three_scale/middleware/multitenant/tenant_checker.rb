module ThreeScale
  module Middleware
    class Multitenant
      class TenantChecker
        include ::ApiAuthentication::HttpAuthentication

        SKIPPED_CONTROLLERS = {
          "admin/api/objects".freeze => true, # this checks objects' tenant_id so we have to skip it
          "provider/domains".freeze => true,
        }.freeze
        private_constant :SKIPPED_CONTROLLERS

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
          return if SKIPPED_CONTROLLERS[@env["action_dispatch.request.path_parameters"][:controller]]

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

          return if master?

          raise TenantLeak.new(object, attribute, original)
        end

        def master?
          return @is_master if defined?(@is_master)

          @master ||= ::Account.unscoped.master

          @is_master = session_of_master? || provider_key_of_master? || token_of_master?
        end

        def session_of_master?
          # this is supposed to match how we get the user_session in app/lib/authenticated_system/request.rb
          # on API calls cookies are not present though, so we need to use safe navigation
          user_session = UserSession.authenticate(@env['action_dispatch.cookies']&.signed&.public_send(:[], :user_session))
          user_session&.user&.account == @master
        end

        def provider_key_of_master?
          return true if token_from_basic_auth == @master.provider_key

          param_places = %w[action_dispatch.request.query_parameters action_dispatch.request.request_parameters]
          possible_keys = %w[provider_key api_key]
          param_places.product(possible_keys).any? { |params, key| @env[params][key] == @master.provider_key }
        end

        def token_of_master?
          token = @env["action_dispatch.request.query_parameters"]["access_token"] ||
            @env["action_dispatch.request.request_parameters"]["access_token"] ||
            token_from_basic_auth
          @master.access_tokens.find_from_value(token)
        end

        def token_from_basic_auth
          @token_from_basic_auth ||= http_authentication # from ApiAuthentication::HttpAuthentication
        end

        # needed by ApiAuthentication::HttpAuthentication#http_authentication
        def request
          @request ||= ActionDispatch::Request.new(@env)
        end
      end
    end
  end
end
