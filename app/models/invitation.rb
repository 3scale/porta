class Invitation < ApplicationRecord
  belongs_to :account

  belongs_to :user

  validates :account, presence: true
  validates :email, presence: true
  validate :email_is_not_taken
  validates :email, uniqueness: { :scope => :account_id, :message => "This invitation has already been sent." } # Do you want to resend it?"

  #OPTIMIZE: use the same format validations in user, account and invitation, add TESTS!
  validates :email, length: { :within => 6..100, :allow_blank => true } #r@a.wk
  validates :email, format: { :with => Authentication::RE_EMAIL_OK, :allow_blank => true,
                              :message => Authentication::MSG_EMAIL_BAD }

  before_create :generate_token
  # :unless is there because after_commit was running itself again and again
  # so after first call it sets the sent_at attribute and breaks the infinite loop
  after_commit :notify_invitee, :on => :create, :unless => :sent?

  attr_protected :accepted_at, :tenant_id

  default_scope -> { ordering { System::Database.oracle? ? sent_at.desc.op('', sql('NULLS LAST')) : sent_at.desc } }

  scope :pending, -> { where(accepted_at: nil) }

  # Build new user on information in this invitation.
  def make_user(params = {})
    self.user= account.users.build_with_fields params.reverse_merge(:email => email, :invitation => self)
  end

  def accepted?
    accepted_at.present?
  end

  def accept!
    update_attribute(:accepted_at, Time.zone.now) unless accepted?
  end

  def resend
    notify_invitee unless accepted?
  end

  private

  def email_is_not_taken
    return unless account
    return if account.users.by_email(email).empty?
    errors.add(:email, 'has been taken by another user')
  end

  def generate_token
    self.token = SecureRandom.hex(16)
  end

  def sent?
    sent_at.present?
  end

  def notify_invitee
    # TODO: maybe subclass to Invitation and ProviderInvitation
    if account.provider?
      ProviderInvitationMailer.invitation(self).deliver_now
    else
      InvitationMailer.invitation(self).deliver_now
    end

    update_column(:sent_at, Time.zone.now)
  end

end
