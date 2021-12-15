# frozen_string_literal: true

class EmailConfiguration < ApplicationRecord
  validates :email, :password, presence: true
  belongs_to :account, required: true

  before_save :set_tenant_id, on: :create

  def smtp_settings
    {
      user_name: username,
      password: password,
      # # This below we do not have to do for SaaS OCP
      # # Can be done in 2nd and 3rd steps
      # address: nil,
      # port: nil,
      # domain: nil,
      # openssl_verify_mode: nil,
      # enable_starttls_auto: nil,
      # domain: nil,
      # authentication: nil
    }.reverse_merge(ActionMailer::Base.smtp_settings)
  end

  protected

  def set_tenant_id
    self.tenant_id ||= account&.id if account&.provider?
  end
end
