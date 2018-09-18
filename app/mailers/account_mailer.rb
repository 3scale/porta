# frozen_string_literal: true

class AccountMailer < ActionMailer::Base

  include Liquid::Assigns
  include CMS::EmailTemplate::MailerExtension

  add_template_helper(SupportEntitlementsHelper)
  add_template_helper(Finance::InvoicesHelper)

  def confirmed(account)
    self.provider_account = account.provider_account

    headers('Return-Path' => from_address(account),
            'X-SMTPAPI' => '{"category": "Account confirmed"}')

    assign_drops assigns(account)

    mail(:template_name => 'account_confirmed',
         :from     => from_address(account),
         :to       => admin_of(account).email,
         :subject  => "Waiting list confirmation")

  end

  def approved(account)
    self.provider_account = account.provider_account

    headers('Return-Path' => from_address(account),
            'X-SMTPAPI' => '{"category": "Account approved"}')

    assign_drops assigns(account)

    mail(:template_name => 'account_approved',
         :from     => from_address(account),
         :to       => admin_of(account).email,
         :subject  => "Registration now active!")

  end

  def rejected(account)
    self.provider_account = account.provider_account

    headers('Return-Path' => from_address(account),
            'X-SMTPAPI' => '{"category": "Account rejected"}')

    assign_drops assigns(account)

    mail(:template_name => 'account_rejected',
         :from     => from_address(account),
         :to       => admin_of(account).email,
         :subject  => "Registration Denied")
  end

  def support_entitlements_assigned(account, effective_since: Time.now.utc, invoice_id: nil)
    self.provider_account = account.provider_account

    @account = account
    @plan = account.bought_cinstance.plan
    @effective_since = effective_since
    @invoice_id = invoice_id

    headers('Return-Path' => from_address(account),
            'X-SMTPAPI' => '{"category": "Assign Entitlements"}')

    mail(from: from_address(account),
         to: ThreeScale.config.redhat_customer_portal.assign_entitlements_email,
         subject: "3scale Notification - Assign Entitlements")
  end

  def support_entitlements_revoked(account, effective_since: Time.now.utc, invoice_id: nil)
    self.provider_account = account.provider_account

    @account = account
    @effective_since = effective_since
    @invoice_id = invoice_id

    headers('Return-Path' => from_address(account),
            'X-SMTPAPI' => '{"category": "Revoke Entitlements"}')

    mail(from: from_address(account),
         to: ThreeScale.config.redhat_customer_portal.revoke_entitlements_email,
         subject: "3scale Notification - Revoke Entitlements")
  end

  private

  def assigns(account)
    {
      :user => Liquid::Drops::User.new(admin_of(account)),
      :domain => account.provider_account.domain,
      :account => Liquid::Drops::Account.new(account),
      :provider => Liquid::Drops::Provider.new(account.provider_account),
      :support_email => admin_of(account.provider_account).email
     }
  end

  def admin_of(account)
    account.admins.first
  end

  def provider(account)
    account.provider_account
  end

  def from_address(account)
    account.provider_account.from_email
  end
end
