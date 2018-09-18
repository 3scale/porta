class UserSession < ApplicationRecord

  TTL = 2.weeks.freeze

  belongs_to :user
  belongs_to :sso_authorization, required: false
  has_one :account, through: :user

  validates :user_id, :key, presence: true

  before_validation :set_unique_key, :on => :create

  scope :password_only, -> { where(sso_authorization_id: nil) }

  attr_readonly :key

  scope :active, -> { where('accessed_at >= ? and revoked_at is null', TTL.ago) }
  scope :stale, -> { where('revoked_at is NOT NULL or accessed_at < ?', TTL.ago) }

  delegate :account, to: :user

  def self.authenticate(key)
    return nil if key.nil?
    self.active.find_by_key(key)
  end

  def self.null
    new
  end

  def sso_login?
    sso_authorization_id.present?
  end

  def revoke!
    return unless persisted?
    self.revoked_at = Time.zone.now
    save!
  end

  def access(request)
    return unless valid?

    update_attributes!(accessed_at: Time.zone.now,
                       ip: request.ip,
                       user_agent: request.user_agent)
  rescue => error
    System::ErrorReporting.report_error(error)
  end

  def user_agent=(value)
    if value != nil
      value = value[0..254]
    end
    self[:user_agent] = value
  end

  private
    def set_unique_key
      self.key = SecureRandom.urlsafe_base64(32)
    end
end
