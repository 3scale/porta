# frozen_string_literal: true

class ProviderUserMailer < ActionMailer::Base
  default from: Rails.configuration.three_scale.support_email,
          'Return-Path' => Rails.configuration.three_scale.support_email

  include MailersHelper
  helper MailersHelper

  def activation(user)
    activation_email(user: user, subject: 'Account Activation')
  end

  def activation_reminder(user)
    activation_email(user: user, subject: 'Account Activation Reminder')
  end

  def lost_password(user)
    @user = user
    @url = provider_password_url(password_reset_token: user.lost_password_token, host: domain(user.account))

    prepare_email(subject: 'Password Recovery', headers: {'X-SMTPAPI' => '{"category": "Lost password"}'}, to: user.email, template: 'provider_lost_password')
  end

  def lost_domain(email, domains)
    @domains = domains
    prepare_email(subject: 'Domain Recovery', headers: {'X-SMTPAPI' => '{"category": "Domain Recovery"}'}, to: email)
  end

  private

  def activation_email(user:, subject:)
    @user = user
    @activate_url = provider_activate_url(activation_code: user.activation_code, host: domain(user.account))
    prepare_email(subject: subject, to: user.email, headers: {'X-SMTPAPI' => '{"category": "Signup Notification"}'})
  end

  def domain(account)
    raise "Using ProviderUserMailer for buyer account #{account.name}(#{account.id})" unless account.master? || account.provider?
    account.admin_domain
  end



  # TODO: The methods below aren't splitted yet - uncomment when ready.
  # ---------------------------------------------------------------------

  # def lost_password(user)
  #   self.provider_account = user.account.provider_account

  #   subject = "#{provider.name} Lost password recovery"

  #   headers(
  #           'Return-Path' => from_address(user),
  #           'X-SMTPAPI' => '{"category": "Lost password"}'
  #           )

  #   # TODO: make lost_password and provider_lost_password mailer method
  #   url = if user.account.buyer?
  #           admin_account_password_url :password_reset_token => user.lost_password_token,
  #           :host                 => domain(user.account)
  #         else
  #           provider_password_url :password_reset_token => user.lost_password_token,
  #           :host                 => domain(user.account)
  #         end

  #   assign_drops :user   => Liquid::Drops::User.new(user),
  #   :provider => Liquid::Drops::Provider.new(self.provider_account),
  #   :domain => Liquid::Drops::Deprecated.new(domain(user.account)),
  #   :url    => url

  #   mail(
  #        :subject => subject,
  #        :template_name => 'lost_password_email',
  #        :to => user.email,
  #        :from => from_address(user)
  #        )

  # end


  # private

  # def admin_url(user)
  #   admin_dashboard_url(:host => user.account.provider_account.domain)
  # end


  # def account_name(user)
  #   user.account.provider_account.try(:org_name) || domain(user.account)
  # end

end
