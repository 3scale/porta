module Authentication
  module Strategy

    # Used for impersonation
    class Token < Base

      def self.expected_params
        %i[token expires_at]
      end

      def authenticate(params)
        if site_account.settings.sso_key && params[:token] && params[:expires_at]
          @redirect_url = params[:redirect_url]
          authenticate_with_sso params[:token], params[:expires_at]
        end
      end

      def authenticate_by_token(token)
        return unless site_account.settings.sso_key

        authenticate_with_sso(token)
      end

      def redirect_to_on_successful_login
        if @redirect_url
          begin
            Addressable::URI.parse(@redirect_url).to_s
          rescue
            nil
          end
        else
          super
        end
      end

      private

      def authenticate_with_sso(token, expires_at = nil)
        encryptor = ThreeScale::SSO::Encryptor.new site_account.settings.sso_key, expires_at.to_i
        user_id, username = encryptor.extract! token

        user = if user_id.present?
                 users.find_by! id: user_id
               else
                 users.find_by! username: username
        end

        can_login?(user) ? user : nil
      rescue ActiveRecord::RecordNotFound
        @error_message = 'User not found'
        nil
      # this happens when we fail to decrypt the message
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature => error
        @error_message = "Invalid SSO Token"
        nil
      # this happens when we fail to validate the decrypted message, right now only if the token expired
      rescue ThreeScale::SSO::ValidationError => error
        @error_message = "Token Expired"
        nil
      end
    end
  end
end
