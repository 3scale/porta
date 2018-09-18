# frozen_string_literal: true
module ThreeScale
  module OAuth2
    class ClientBase
      class ClientError < StandardError
        include Bugsnag::MetaData

        def initialize(error_message, options = {})
          self.bugsnag_meta_data = {
            oauth2: options.to_h
          }
          super error_message
        end
      end

      class NoAccessTokenError < ClientError
        def initialize(options)
          super 'Missing access_token, authenticate first', options
        end
      end

      class UnsupportedFlowError < ClientError
        def initialize(options = {})
          super 'Unsupported OAuth flow', options
        end
      end

      class InvalidParamError < StandardError; end

      class CallbackUrl
        def self.call(base_url, sso_name, query_options)
          new(base_url, sso_name, query_options).call
        end

        def initialize(base_url, sso_name, query_options)
          @base_url = base_url
          @sso_name = sso_name
          @query_options = query_options
        end

        def call
          url = base_url.dup
          url << '/auth' if base_url.exclude?('/auth')
          url << "/#{sso_name}/callback"
          url << "?#{query_options.to_query}" if query_options.present?
          url
        end

        protected

        attr_reader :base_url, :sso_name, :query_options
      end

      # @return [ThreeScale::OAuth2::Client::Authentication]
      attr_reader :authentication

      # @return [ThreeScale::OAuth2::Client::ClientBase]
      attr_reader :client

      attr_reader :raw_info

      delegate :client_id, to: :authentication
      delegate :token, to: :access_token
      delegate :logger, to: 'Rails'

      # @param [ThreeScale::OAuth2::Client::Authentication] authentication
      def initialize(authentication)
        @authentication = authentication
        @client = ::OAuth2::Client.new(@authentication.client_id, @authentication.client_secret, options)
        @raw_info = {}
      end

      # @param [String] code
      # @param [ActionDispatch::Request] request
      # @return [ThreeScale::OAuth2::UserData,ThreeScale::OAuth2::ErrorData] user_data
      def authenticate!(code, request)
        fetch_access_token(code, request)
        fetch_raw_info
        user_data
      rescue ::OAuth2::Error, InvalidParamError => error
        logger.error { "[OAuth2] [#{self.class.name}] Failed to get Access Token for Code #{code} with: #{error}" }
        access_token_error_data
      rescue ::Faraday::SSLError
        i18n_error_data('invalid_certificate')
      rescue ::Faraday::ConnectionFailed
        i18n_error_data('connection_failed')
      rescue ::Faraday::ClientError => error
        i18n_error_data('client_error', message: error.message)
      end

      def fetch_access_token(code, request)
        access_token_options = authenticate_options(request)
        logger.debug { "[OAuth2] Requesting Access Token for Code #{code} with options: #{access_token_options}" }
        @access_token = client.auth_code.get_token(code, access_token_options)
        logger.debug { "[OAuth2] Got Access Token #{access_token.token} For Code #{code}" }
        access_token
      end

      def fetch_raw_info
        @raw_info = access_token.get(user_info_url).parsed.presence || @raw_info
        logger.debug { "[OAuth2] Got raw info: #{raw_info}" }
        raw_info
      end

      def access_token
        @access_token or raise NoAccessTokenError, authentication
      end

      def user_data
        UserData.build(self)
      end

      def authorize_url(base_url, query_options = {})
        client.auth_code.authorize_url(redirect_uri: callback_url(base_url, query_options), scope: scopes)
      end

      def callback_url(base_url, query_options = {})
        CallbackUrl.call(base_url, authentication.system_name, query_options)
      end

      def email
        nil
      end

      def email_verified?
        false
      end

      def username
        nil
      end

      def org_name
        nil
      end

      def uid
        raw_info[authentication.identifier_key]
      end

      def authentication_id
        uid
      end

      def kind
        'base'
      end

      def authenticate_options(request)
        {}
      end

      def id_token
        access_token.params['id_token']
      end

      private

      def scopes
        nil
      end

      def user_info_url
        authentication.user_info_url
      end

      def options
        authentication.options.to_hash
      end

      def access_token_error_data
        i18n_error_data('code_incorrect_or_expired')
      end

      def i18n_error_data(key, **options)
        ErrorData.new(error: I18n.t(key, scope: %i[errors messages oauth], **options))
      end
    end
  end
end
