require 'bcrypt'
module Authentication
  module ByPassword
    extend ActiveSupport::Concern

    # strong passwords
    STRONG_PASSWORD_MIN_SIZE = 16
    # All printable characters in ASCII, from 'space' (32) to ~ (126)
    # at least STRONG_PASSWORD_MIN_SIZE characters
    RE_STRONG_PASSWORD = /\A[ -~]{#{STRONG_PASSWORD_MIN_SIZE},64}\z/
    STRONG_PASSWORD_FAIL_MSG = "Password must be at least #{STRONG_PASSWORD_MIN_SIZE} characters long, and contain only valid characters.".freeze

    included do
      # We only need length validations as they are already set in Authentication::ByPassword
      has_secure_password validations: false

      validates_presence_of :password, if: :validate_password?

      validates_confirmation_of :password, allow_blank: true

      validates :password, format: { :with => RE_STRONG_PASSWORD, :message => STRONG_PASSWORD_FAIL_MSG,
                                     if: -> { validate_strong_password? } }

      validates :lost_password_token, :password_digest, length: { maximum: 255 }

      attr_accessible :password, :password_confirmation

      scope :with_valid_password_token, -> { where { lost_password_token_generated_at >= 24.hours.ago } }

      alias_method :authenticated?, :authenticate
    end

    class_methods do
      def find_with_valid_password_token(token)
        with_valid_password_token.find_by(lost_password_token: token)
      end
    end

    def validate_password?
      password_digest_changed? || (signup.by_user? && password_digest.blank?)
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
      return unless update_columns(lost_password_token: token, lost_password_token_generated_at: Time.current)

      token
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
  end
end
