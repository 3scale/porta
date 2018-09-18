require_dependency 'authentication/strategy'

module Authentication
  module Strategy
    class Procedure
      attr_reader :strategy, :users, :params, :user_data

      delegate :authentication_provider, to: :strategy

      # @param [ThreeScale::OAuth2::UserData] user_data

      def initialize(strategy, users, params, user_data)
        @strategy  = strategy
        @users     = users
        @params    = params
        @user_data = user_data
      end

      private

      delegate :uid, to: :user_data
    end

    class Base
      include DeveloperPortal::Engine.routes.url_helpers

      attr_reader :site_account, :admin_domain, :user_for_signup, :new_user_created

      def initialize(site_account, admin_domain = false)
        @site_account     = site_account
        @admin_domain     = admin_domain
        @user_for_signup  = nil
        @new_user_created = false
      end

      def name
        @name ||= self.class.name.demodulize.underscore
      end

      def new_user_created?
        new_user_created
      end

      # URL to redirect after a sucessful login, also, if session[:redirect_to] is nil.
      # this implementation redirects_to root path
      def redirect_to_on_successful_login
        root_path
      end

      # Useful for remotely hosted authentication strategies such as Janrain strategy.
      def redirects_to_signup?
        false
      end

      # This is a callback automatically by new signups controller
      def on_new_user(user, session)
      end

      # This is called automatically by new signups controller
      def on_signup_complete(session)
      end

      # This is called automatically by sessions controller
      def on_signup(session)
      end

      def signup_path(params)
        DeveloperPortal::Engine.routes.url_helpers
            .signup_path(params.except(:action, :controller))
      end

      # This is the template rendered by sessions controller, usually the login form
      def template
        "sessions/strategies/#{name}"
      end

      def track_signup_options(options = {})
        {strategy: 'other'}
      end

      def authentication_provider; end

      def authentication_provider_id
        authentication_provider.try(:id)
      rescue Authentication::Strategy::Oauth2Base::MissingAuthenticationProvider
        nil
      end
    end
  end
end
