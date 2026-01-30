require 'bcrypt'
module Authentication
  module ByPassword

    # Wrapper for rails `has_secure_password`
    module HasSecurePassword
      extend ActiveSupport::Concern

      included do
        # We only need length validations as they are already set in Authentication::ByPassword
        has_secure_password validations: false
        prepend AuthenticateWithHasSecurePassword
      end

      def password_required?
        password_digest.blank? || password_digest_changed?
      end

      module AuthenticateWithHasSecurePassword
        # Can't use `#authenticate` if the `password_digest` field is nil
        def authenticate(*)
          password_digest? && super
        end
      end

      def authenticated?(unencrypted_password)
        authenticate(unencrypted_password)
      end

      def just_changed_password?
        saved_change_to_password_digest?
      end
    end

    # Stuff directives into including module
    def self.included( recipient )
      recipient.class_eval do
        include HasSecurePassword

        # Virtual attribute for the unencrypted password
        #attr_accessor :password

        validates_presence_of :password, if: :password_required?

        validates_confirmation_of :password, allow_blank: true
      end
    end # #included directives
  end
end
