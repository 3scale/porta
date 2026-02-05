# This is based on Authorization::StatefulRoles from the Restful Authentication plugin.
module User::States
  extend ActiveSupport::Concern

  included do
    include AfterCommitQueue

    before_create :make_activation_code

    state_machine initial: :pending do
      state :pending
      state :active
      state :suspended
      state :email_unverified

      before_transition to: :active do |user|
        user.make_active
      end

      after_transition to: :active do |user|
        user.notify_activation
      end

      after_transition to: :suspended do |user|
        user.kill_user_sessions
      end

      before_transition to: :email_unverified do |user|
        user.generate_email_verification_token
      end

      event :activate do
        transition pending: :active
      end

      event :suspend do
        transition active: :suspended
        transition suspended: :suspended
      end

      event :unsuspend do
        transition suspended: :active
      end

      event :email_unverify do
        transition active: :email_unverified
      end

      event :email_verify do
        transition email_unverified: :active
      end
    end
  end

  def activate_email(email)
    activate if pending? && self.email == email
  end

  def notify_activation
    if self == account.try!(:first_admin) && account.try!(:provider?)
      run_after_commit do
        ThreeScale::Analytics.track(self, 'Activated account')
      end
    end
  end

  def make_active
    self.activated_at    = Time.zone.now
    self.activation_code = nil

    account.upgrade_state! if account && account.created?
  end

  def make_activation_code
    self.activation_code = self.class.make_token
  end

  def activate_on_minimal_or_sample_data?
    (minimal_signup? || signup.sample_data?) && password.present? && !account.try!(:bought_account_plan).try!(:approval_required?)
  end

  def generate_email_verification_token
    self.email_verification_code = self.class.make_token
  end
end

