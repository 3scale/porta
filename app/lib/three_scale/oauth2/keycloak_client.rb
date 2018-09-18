# frozen_string_literal: true
module ThreeScale
  module OAuth2
    class KeycloakClient < ClientBase
      class MissingRealmError < ClientError
        def initialize(options)
          super 'Missing realm option', options
        end
      end

      def username
        raw_info['username'].presence || raw_info['preferred_username']
      end

      def email
        raw_info['email']
      end

      def email_verified?
        raw_info['email_verified']
      end

      # TODO: to be defined as a mapper in Keycloak
      def org_name
        raw_info['org_name']
      end

      def kind
        'keycloak'
      end

      def uid
        raw_info['sub']
      end

      def realm
        authentication.options.site || raise(MissingRealmError, authentication.options)
      end

      def authenticate_options(request)
        {
          redirect_uri: RedirectUri.call(request)
        }
      end

      private

      class RedirectUri

        NOT_ALLOWED_PARAMS = %w[code].freeze

        def self.call(request)
          new(request).call
        end

        def initialize(request)
          @uri     = URI(request.url)
          @request = request
        end

        def call
          clean_query_params
          add_host
          uri_string
        end

        def uri_string
          @uri.to_s
        end

        def clean_query_params
          @uri.query = parsed_query_params.except(*NOT_ALLOWED_PARAMS).to_query.presence
        end

        def parsed_query_params
          Rack::Utils.parse_query(@uri.query)
        end

        def add_host
          @uri.host = @request.try(:real_host).presence || @request.host
        end
      end

      def user_info_url
        "#{realm}/protocol/openid-connect/userinfo"
      end

      def options
        super.merge(
          realm: realm,
          token_url: "#{realm}/protocol/openid-connect/token",
          authorize_url: "#{realm}/protocol/openid-connect/auth"
        )
      end
    end
  end
end
