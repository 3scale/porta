module Liquid
  module Drops
    class AuthenticationProvider < Drops::Base
      allowed_name :authentication_provider

      def initialize(authentication_provider, site_account = authentication_provider.account)
        @site_account = site_account
        @authentication_provider = authentication_provider
        @client = ThreeScale::OAuth2::Client.build(authentication_provider)
      end

      hidden
      delegate :id, to: :authentication_provider

      desc 'Name of the SSO Integration'
      delegate :name, to: :authentication_provider

      hidden
      delegate :system_name, to: :authentication_provider

      desc 'Kind of the SSO Integration. Useful for styling.'
      delegate :kind, to: :authentication_provider

      hidden
      delegate :client_id, to: :@client

      desc 'OAuth authorize url.'
      delegate :authorize_url, to: :oauth_flow

      desc 'OAuth callback url.'
      delegate :callback_url, to: :oauth_flow

      private

      def oauth_flow
        request = context.registers[:request]
        OauthFlowPresenter.new(@authentication_provider, request)
      end

      attr_reader :authentication_provider
    end
  end
end
