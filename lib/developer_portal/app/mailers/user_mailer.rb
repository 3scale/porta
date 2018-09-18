class UserMailer < ActionMailer::Base

  include Liquid::Assigns

  include CMS::EmailTemplate::MailerExtension

  #TODO: dry this one
  def signup_notification(user)
    provider = self.provider_account = user.account.provider_account

    subject = user.account.provider? ? "3scale account confirmation" : "#{account_name(user)} API account confirmation"

    headers(
      'Return-Path' => from_address(user),
      'X-SMTPAPI' => '{"category": "Signup Notification"}'
    )

    if user.activation_code
      activate_url = if user.account.provider?
                       provider_activate_url(activation_code: user.activation_code, host: domain(user))
                     else
                       developer_portal.activate_url(activation_code: user.activation_code, host: domain(user))
                     end
    end

    assign_drops user: Liquid::Drops::User.new(user),
                 domain: Liquid::Drops::Deprecated.wrap(domain(user)),
                 account_name: Liquid::Drops::Deprecated.wrap(account_name(user)),
                 account: Liquid::Drops::Account.wrap(user.account),
                 provider: Liquid::Drops::Provider.wrap(user.account.provider_account),
                 url: activate_url,
                 admin_url: Liquid::Drops::Deprecated.wrap(admin_url(user))

    mail(
      template_name: 'signup_notification_email',
      subject: subject,
      to: user.email,
      from: from_address(user)
    )
  end

  # TODO: split into provider_user_mailer.rb!
  def lost_password(user)
    self.provider_account = user.account.provider_account

    subject = "#{provider.name} Lost password recovery. (Valid for 24 hours)"

    headers(
            'Return-Path' => from_address(user),
            'X-SMTPAPI' => '{"category": "Lost password"}'
    )

    # TODO: make lost_password and provider_lost_password mailer method
    url = if user.account.buyer?
            developer_portal.admin_account_password_url password_reset_token: user.lost_password_token, host: domain(user)
          else
            provider_password_url password_reset_token: user.lost_password_token, host: domain(user)
          end

    assign_drops :user   => Liquid::Drops::User.new(user),
    :provider => Liquid::Drops::Provider.new(self.provider_account),
    :domain => Liquid::Drops::Deprecated.wrap(domain(user)),
    :url    => url

    mail(
         :subject => subject,
         :template_name => 'lost_password_email',
         :to => user.email,
         :from => from_address(user)
    )

  end

  private

  def admin_url(user)
    developer_portal.admin_dashboard_url(:host => user.account.provider_account.domain)
  end

  def domain(user)
    account = user.account

    if account.master?
      account.domain
    elsif account.provider?
      account.admin_domain
    else
      account.provider_account.domain
    end
  end

  def account_name(user)
    user.account.provider_account.try(:org_name) || domain(user)
  end

  def from_address(user)
    user.account.provider_account.try(:from_email) || Rails.configuration.three_scale.noreply_email
  end
end
