require 'bcrypt'
module Authentication
  module ByPassword
    extend ActiveSupport::Concern

    # strong passwords
    SPECIAL_CHARACTERS = '-+=><_$#.:;!?@&*()~][}{|'
    RE_STRONG_PASSWORD = /
      \A
        (?=.*\d) # number
        (?=.*[a-z]) # lowercase
        (?=.*[A-Z]) # uppercase
        (?=.*[#{Regexp.escape(SPECIAL_CHARACTERS)}]) # special char
        (?!.*\s) # does not end with space
        .{8,} # at least 8 characters
      \z
    /x
    STRONG_PASSWORD_FAIL_MSG = "Password must be at least 8 characters long, and contain both upper and lowercase letters, a digit and one special character of #{SPECIAL_CHARACTERS}.".freeze

    included do
      # We only need length validations as they are already set in Authentication::ByPassword
      has_secure_password validations: false

      validates_presence_of :password, if: :password_required?

      validates_confirmation_of :password, allow_blank: true

      validates :password, format: { :with => RE_STRONG_PASSWORD, :message => STRONG_PASSWORD_FAIL_MSG,
                                     if: -> { password_required? && provider_requires_strong_passwords? } }
      validates :password, length: { minimum: 6, allow_blank: true,
                                     if: -> { password_required? && !provider_requires_strong_passwords? } }

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

    def password_required?
      signup.by_user? && (password_digest.blank? || password_digest_changed?)
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
      password_digest.present?
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
