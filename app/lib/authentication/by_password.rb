require 'bcrypt'
module Authentication
  module ByPassword

    # Migrate to HasSecurePassword due to leak in https://github.com/3scale/system/issues/8111
    module HasSecurePassword
      extend ActiveSupport::Concern

      included do
        # We only need length validations as they are already set in Authentication::ByPassword
        has_secure_password validations: false
        prepend AuthenticateWithHasSecurePassword
      end

      def password_required?
        (password_digest.blank? || password_digest_changed?) && super
      end

      module AuthenticateWithHasSecurePassword
        # Can't use `#authenticate` if the `password_digest` field is nil
        def authenticate(*)
          password_digest? && super
        end
      end

      # If there is something set in password_digest then authenticate with has_secure_password
      # Otherwise use the old authentication method
      def authenticated?(unencrypted_password)
        password_digest? ? authenticate(unencrypted_password) : super
      end

      # Migrate old password to new password_digest
      # If the password_digest is already set, skip
      def transparently_migrate_password(unencrypted_password)
        return if unencrypted_password.blank? || password_digest.present?
        self.password = unencrypted_password
        ThreeScale::Analytics.user_tracking(self).track('Migrated to BCrypt')
        update_columns(password_digest: password_digest, salt: nil, crypted_password: nil)
      end

      def just_changed_password?
        previous_changes.key?('password_digest') || super
      end

      private

      def password_changed?
        password_digest_changed? || super
      end
    end

    # Stuff directives into including module
    def self.included( recipient )
      recipient.extend( ModelClassMethods )
      recipient.class_eval do
        include ModelInstanceMethods
        include HasSecurePassword

        # Virtual attribute for the unencrypted password
        #attr_accessor :password

        validates_presence_of :password, if: :password_required?

        validates_confirmation_of :password, allow_blank: true
      end
    end # #included directives

    #
    # Class Methods
    #
    module ModelClassMethods
      # This provides a modest increased defense against a dictionary attack if
      # your db were ever compromised, but will invalidate existing passwords.
      # See the README and the file config/initializers/site_keys.rb
      #
      # It may not be obvious, but if you set REST_AUTH_SITE_KEY to nil and
      # REST_AUTH_DIGEST_STRETCHES to 1 you'll have backwards compatibility with
      # older versions of restful-authentication.
      def password_digest(password, salt)
        digest = REST_AUTH_SITE_KEY
        REST_AUTH_DIGEST_STRETCHES.times do
          digest = secure_digest(digest, salt, password, REST_AUTH_SITE_KEY)
        end
        digest
      end
    end # class methods

    #
    # Instance Methods
    #
    module ModelInstanceMethods

      # Encrypts the password with the user salt
      def encrypt(password)
        self.class.password_digest(password, salt)
      end

      def authenticated?(password)
        ActiveSupport::SecurityUtils.variable_size_secure_compare(crypted_password.to_s, encrypt(password))
      end

      # FIXME: This method is not used anymore as we removed the callback
      #   before_save :encrypt_password
      # Keeping the method for backward compatibility tests. See test/unit/authentication/by_has_secure_password_test.rb
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = encrypt(password)
      end

      def password_required?
        crypted_password.blank? || !password.blank?
      end

      def just_changed_password?
        previous_changes.key?('crypted_password')
      end

      private
      def password_changed?
        encrypt(password) != crypted_password
      end
    end # instance methods
  end
end
