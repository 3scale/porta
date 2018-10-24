# frozen_string_literal: true

module ThreeScale
  module OAuth2
    class ServiceDiscoveryClient < ClientBase
      attr_reader :state

      def kind
        'service_discovery'
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


      def uid
        raw_info['sub'] || username || raw_info.dig('metadata', 'uid') # last is for OpenShift OAuth server
      end

      def authenticate_options(request)
        {
          redirect_uri: RedirectUri.call(self, request)
        }
      end

      def scopes
        'user:full'
      end

      def options
        super.merge(auth_scheme: :basic_auth)
      end

      # TODO: Refactor! It is the similar to ThreeScale::OAuth2::RedhatCustomerPortalClient::RedirectUri
      #
      class RedirectUri < ThreeScale::OAuth2::ClientBase::CallbackUrl

        PARAMS_NOT_ALLOWED = %i[code action controller state].freeze

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
