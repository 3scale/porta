module Authentication
  module Strategy
    class Cas < Internal

      def authenticate params

        return super unless params[:ticket]

        res = HTTPClient.get validate_url_with_query params[:ticket]

        return false unless [200, 303].include?(res.code) && res.body.start_with?("yes\n")

        @profile_id = res.body.split("\n")[1]
        user = site_account.managed_users.find_by_cas_identifier @profile_id

        return false unless user

        if user.can_login?
          user
        else
          self.error_message = inactive_user_message
          false
        end
      end

      # this is called automatically by session controller
      def redirects_to_signup?
        !@profile_id.nil?
      end

      # this is called automatically by session controller
      #   it allows me to hook cas_identifier into session before redirecting to signup
      def on_signup session
        raise "CAS identifier not set by previous authentication!" unless @profile_id
        session[:cas_identifier] = @profile_id
      end

      def on_signup_complete session
        session[:cas_identifier] = nil
      end

      def on_new_user user, session
        if user.cas_identifier = session[:cas_identifier]
          @user_for_signup = user
        end
      end

      # /login path is standard for CAS servers
      def login_url
        "#{cas_server_url}/login"
      end

      def login_url_with_service
        login_url + "?service=" + URI.escape(service)
      end

      # /validate path is standard for CAS servers
      def validate_url
        "#{cas_server_url}/validate"
      end

      def validate_url_with_query ticket
        validate_url + "?" + {:service => service, :ticket => ticket}.to_param
      end

      def service
        # this is pathetic since it needs .dev:3000 or similar on localhost
        # also, we don't have request to use ThreeScale::DevDomain. bleaght.
        # @service ||= create_session_url :host => site_account.domain

        host = site_account.domain
        host += ".#{ThreeScale.config.dev_gtld}:3000" if Rails.env.development?
        create_session_url :host => host
      end

      protected
        def cas_server_url
          @cas_server_url ||= site_account.settings.cas_server_url || raise(StandardError.new("You need to configure the CAS server URL"))
        end

    end
  end
end
