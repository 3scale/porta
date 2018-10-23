# frozen_string_literal: true

module ThreeScale
  module OAuth2
    class ServiceDiscoveryClient < ClientBase
      def username
        raw_info['username'].presence || raw_info['preferred_username']
      end

      def email
        raw_info['email']
      end

      def email_verified?
        raw_info['email_verified']
      end

      def kind
        'service_discovery'
      end

      # TODO: differs on Keycloak and on Openshift OAuth server
      def uid
        raw_info['sub'] || username || raw_info.dig('metadata', 'uid') # last is for OpenShift OAuth server
      end

      def authenticate_options(request)
        {
            # TODO: see service_discovery_helper.rb
            # I need to construct this dynamically through a request
            redirect_uri: 'http://master-account-admin.example.com.lvh.me:3000/auth/service-discovery/callback?self_domain=provider-admin.example.com.lvh.me'
        }
      end
    end
  end
end
