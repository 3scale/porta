module Authentication
  module Strategy

    class Internal < Sso

      def authenticate params
        authenticate_with_username_and_password(params[:username], params[:password]) || super(params)
      end

      def invalid_credentials_message
        "Incorrect email or password. Please try again."
      end

      def track_signup_options(options = {})
        {strategy: 'credentials'}
      end

      def error_message=(message)
        @error_message ||= message
      end

      private

      def authenticate_with_username_and_password username_or_email, password
        user = users.find_by_username_or_email username_or_email
        if user && user.authenticated?(password)
          user.transparently_migrate_password(password)
          user if can_login?(user)
        else
          @error_message = invalid_credentials_message
          nil
        end
      end
    end
  end
end
