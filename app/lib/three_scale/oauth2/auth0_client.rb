module ThreeScale
  module OAuth2
    class Auth0Client < ClientBase

      def uid
        raw_info['sub']
      end

      def authentication_id
        raw_info['user_id']
      end

      def email
        raw_info['email']
      end

      def email_verified?
        raw_info['email_verified']
      end

      def username
        raw_info['nickname']
      end

      def kind
        'auth0'.freeze
      end

      def site
        authentication.options.site || 'http://example.com'
      end

      def authenticate_options(request)
        { redirect_uri: request.url }
      end

      def scopes
        'openid profile email'
      end

      def callback_url(base_url, query_options = {})
        if base_url.include?('invitations'.freeze)
          _, url, token = base_url.partition(%r{\S*/auth/invitations})
          base_url      = "#{url}/#{kind}"
          token         = token.remove('/').presence
          query_options = query_options.merge(state: token) if token
        end

        super(base_url, query_options)
      end

      private

      def user_info_url
        'userinfo'
      end

      def options
        super.merge(
          site: site,
          token_url: "#{site}/oauth/token",
          authorize_url: "#{site}/authorize"
        )
      end
    end
  end
end
