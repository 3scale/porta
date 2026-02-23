require 'bcrypt'
module Authentication
  module ByPassword
    extend ActiveSupport::Concern

    # strong passwords
    STRONG_PASSWORD_MIN_SIZE = 15

    included do
      # We only need length validations as they are already set in Authentication::ByPassword
      has_secure_password validations: false

      before_validation :normalize_password, if: :validate_password?

      validates_presence_of :password, if: :validate_password?

      validates_confirmation_of :password, allow_blank: true

      validates :password, length: { minimum: STRONG_PASSWORD_MIN_SIZE }, if: :validate_strong_password?

      validates :lost_password_token, :password_digest, length: { maximum: 255 }

      attr_accessible :password, :password_confirmation, as: %i[default member admin]

      scope :with_valid_password_token, -> { where { lost_password_token_generated_at >= 24.hours.ago } }

      alias_method :authenticate_without_normalization, :authenticate
    end

    class_methods do
      def find_with_valid_password_token(token)
        with_valid_password_token.find_by(lost_password_token: token)
      end
    end

    def validate_password?
      # The password changed or it's a new record that must provide a password
      will_save_change_to_password_digest? || (new_record? && signup.by_user?)
    end

    def validate_strong_password?
      return false if Rails.configuration.three_scale.strong_passwords_disabled
      return false if signup.sample_data?

      validate_password?
    end

    def just_changed_password?
      saved_change_to_password_digest?
    end

    def expire_password_token
      update_columns(lost_password_token_generated_at: nil)
    end

    def generate_lost_password_token
      token = SecureRandom.hex(32)
      self.lost_password_token = token
      self.lost_password_token_generated_at = Time.current

      token if save
    end

    def generate_lost_password_token!
      return unless generate_lost_password_token

      if account.provider?
        ProviderUserMailer.lost_password(self).deliver_later
      else
        UserMailer.lost_password(self).deliver_later
      end
    end

    def update_password(new_password, new_password_confirmation)
      self.password              = new_password
      self.password_confirmation = new_password_confirmation
      reset_lost_password_token if valid?
      save
    end

    def using_password?
      password_digest_in_database.present?
    end

    def can_set_password?
      account.password_login_allowed? && !using_password?
    end

    def special_fields
      %i[password password_confirmation]
    end

    def reset_lost_password_token
      self.lost_password_token = nil
    end

    raise "FIXME" if Gem::Version.new(Rails.version) >= Gem::Version.new("8.1")
    # To avoid all this logic, from Rails 8.1+ we can use
    # `ActiveModel::Attributes::Normalization`, so `normalizes` method
    # works with virtual attributes like `password` and `password_validation`
    # and normalizes on assignment rather than before_validation
    def normalize_password
      if password.present?
        normalized = password.unicode_normalize(:nfc)
        self.password = normalized unless password == normalized
      end

      if password_confirmation.present?
        normalized_confirmation = password_confirmation.unicode_normalize(:nfc)
        self.password_confirmation = normalized_confirmation unless password_confirmation == normalized_confirmation
      end
    end

    def authenticate(password)
      authenticate_without_normalization(password&.unicode_normalize(:nfc))
    end
    alias_method :authenticated?, :authenticate
  end
end
