class SSOAuthorization < ApplicationRecord
  attr_readonly :uid, :authentication_provider_id, :user_id

  belongs_to :user, inverse_of: :sso_authorizations
  belongs_to :authentication_provider, inverse_of: :sso_authorizations
  has_many :user_sessions, dependent: :destroy

  validates :uid, :authentication_provider, :user, presence: true
  validates :uid, uniqueness: { scope: :authentication_provider_id }
  validates :uid, length: { maximum: 255 }

  scope :newest, -> { order(updated_at: :desc).first }

  def mark_as_used(id_token)
    self.id_token = id_token
    self.updated_at = Time.now.utc
  end

  def self.find_or_build_as_used(user:, uid:, authentication_provider:, id_token: nil)
    authorization  = user.sso_authorizations
        .find_or_initialize_by(uid: uid, authentication_provider: authentication_provider)
    authorization.mark_as_used(id_token)
    authorization
  end
end
