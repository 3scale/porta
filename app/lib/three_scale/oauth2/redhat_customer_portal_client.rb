# frozen_string_literal: true

module ThreeScale
  module OAuth2
    class RedhatCustomerPortalClient < KeycloakClient
      def kind
        'redhat_customer_portal'
      end

      def authenticate_options(request)
        # used by #authenticate! -> OAuth2::Strategy::AuthCode#get_token -> OAuth2::Client#get_token
        {
          redirect_uri: RedirectUri.call(self, request)
        }
      end

      attr_reader :state

      class ImplicitFlow < RedhatCustomerPortalClient
        def initialize(*)
          super
          @state = SecureRandom.hex
        end

        def fetch_access_token(_code, request)
          validate_state!(request)
          @access_token = ::OAuth2::AccessToken.from_kvform(client, request.params.to_query)
          logger.debug { "[OAuth2] Got Access Token #{access_token.token} by implicit flow" }
          access_token
        end

        def scopes
          'openid'
        end

        def response_type
          'id_token token'
        end

        def authorize_url(base_url, query_options = {})
          client.implicit.authorize_url(
            redirect_uri: callback_url(base_url, query_options.except(:state)),
            scope: scopes,
            response_type: response_type,
            state: query_options.fetch(:state, state),
            nonce: SecureRandom.hex
          )
        end

        private

        def validate_state!(request)
          raise InvalidParamError, 'Invalid state param.' unless valid_state?(request)
        ensure
          request.session.delete(:state)
        end

        def valid_state?(request)
          request.params[:state].presence == request.session[:state].presence
        end

        def access_token_error_data
          i18n_error_data('token_incorrect_or_expired')
        end
      end

      class RedirectUri < ThreeScale::OAuth2::ClientBase::CallbackUrl

        PARAMS_NOT_ALLOWED = %i[code action controller].freeze

        def self.call(client, request)
          new(client, request).call
        end

        def initialize(client, request)
          @client = client
          @request = request
        end

        def base_url
          @base_url ||= ThreeScale::Domain.callback_endpoint(request, callback_account, host)
        end

        def sso_name
          @sso_name ||= client.authentication.system_name
        end

        def query_options
          @query_options ||= begin
            opts = { self_domain: self_domain }

            state = client.state
            opts[:state] = request.session[:state] = state if state

            request.params.symbolize_keys.except(*PARAMS_NOT_ALLOWED).merge(opts)
          end
        end

        private

        def self_domain
          request.try(:real_host).presence || request.host
        end

        def callback_account
          client.authentication.account
        end

        def host
          Account.master.self_domain
        end

        attr_reader :client, :request
      end

    end
  end
end
