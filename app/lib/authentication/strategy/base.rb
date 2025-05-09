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
      include System::UrlHelpers.cms_url_helpers

      attr_reader :site_account, :admin_domain, :user_for_signup, :new_user_created, :error_message

      def self.expected_params
        raise NotImplementedError, "expected #{self} to implement #{__method__}"
      end

      def initialize(site_account, admin_domain = false)
        @site_account     = site_account
        @admin_domain     = admin_domain
        @user_for_signup  = nil
        @new_user_created = false

        Rails.logger.debug("Trying to log in by #{name} auth strategy")
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

      # Whether we should run the bot check for this strategy
      def bot_protected?
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
        permitted_params = params.respond_to?(:permit!) ? params.dup.permit! : params
        System::UrlHelpers.cms_url_helpers.signup_path(permitted_params.except(:action, :controller))
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
      rescue Authentication::Strategy::OAuth2Base::MissingAuthenticationProvider
        nil
      end

      def error_message=(message)
        @error_message ||= message
      end

      def inactive_user_message
        I18n.t("errors.messages.inactive_account")
      end

      protected

      def users
        @_users ||= begin
                      if admin_domain
                        site_account.users
                      else
                        site_account.buyer_users
                      end
                    end
      end

      # check if the user can login and if not it sets an <tt>error_message</tt>
      def can_login?(user)
        if user.can_login?
          true
        else
          self.error_message = inactive_user_message
          false
        end
      end
    end
  end
end
