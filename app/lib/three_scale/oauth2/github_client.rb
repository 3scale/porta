module ThreeScale
  module OAuth2
    class GithubClient < ClientBase
      def uid
        raw_info['id']
      end

      def email
        primary_email
      end

      def email_verified?
        true
      end

      def username
        raw_info['login']
      end

      def kind
        'github'
      end

      def org_name
        raw_info['company']
      end

      private

      def scopes
        'user:email'
      end

      def user_info_url
        'user'
      end

      def options
        super.merge(
          :site => 'https://api.github.com',
          :authorize_url => 'https://github.com/login/oauth/authorize',
          :token_url => 'https://github.com/login/oauth/access_token'
        )
      end

      def primary_email
        primary = emails.find{ |i| i['primary'] && i['verified'] }
        primary && primary['email'] || nil
      end

      def emails
        access_token.options[:mode] = :query
        @emails ||= access_token.get('user/emails', :headers => { 'Accept' => 'application/vnd.github.v3' }).parsed
      end
    end
  end
end
