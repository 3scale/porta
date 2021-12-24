# frozen_string_literal: true

class EmailConfiguration < ApplicationRecord

  validates :email, :password, :user_name, :authentication, :domain, :tls, :address, length: { maximum: 255 }

  validates :email, :password, :user_name, presence: true
  validates :email, format: { with: Authentication::RE_EMAIL_OK, message: Authentication::MSG_EMAIL_BAD }
  validates :email, uniqueness: { case_sensitive: false, message: "This email address is already used." }
  validates :address, :domain, format: { with: Authentication::RE_DOMAIN_OK }, allow_nil: true
  validates :address, presence: true, unless: :only_auth_changes?
  validates :authentication, inclusion: { in: %w[plain login cram_md5] }, allow_nil: true
  validates :openssl_verify_mode, inclusion: { in: [OpenSSL::SSL::VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE] }, allow_nil: true
  validates :tls, inclusion: { in: %w[starttls starttls_auto tls no] }, allow_nil: true
  validates :port, inclusion: { in: 1..65535 }, allow_nil: true

  belongs_to :account, optional: false
  validate :account_is_provider

  before_save :set_tenant_id, on: :create

  scope :for, ->(search_email) {
    where arel_table[:email].matches(search_email.gsub(/([_%\\])/, '\\\\\\1'), "\\", false)
  }

  def local_settings
    {
      user_name: user_name,
      password: password,
      address: address,
      port: port,
      domain: domain,
      authentication: authentication,
    }.compact.merge(tls_settings)
  end

  def tls_settings
    return {} unless tls

    {
      enable_starttls_auto: tls == "starttls_auto",
      enable_starttls: tls == "starttls",
      tls: tls == "tls",
    }
  end

  def smtp_settings
    base_settings = only_auth_changes? ? ActionMailer::Base.smtp_settings : {}
    base_settings.merge local_settings
  end

  def only_auth_changes?
    %i[address port tls authentication openssl_verify_mode].none? { |attr| send(attr) }
  end

  protected

  def set_tenant_id
    self.tenant_id ||= account&.id if account&.provider? && !account&.master?
  end

  private

  def account_is_provider
    errors.add(:account_id, "is not a provider account") unless account.try(:provider?)
  end
end
