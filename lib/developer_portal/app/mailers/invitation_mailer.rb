class InvitationMailer < ActionMailer::Base

  include Liquid::Assigns
  include DeveloperPortal::Engine.routes.url_helpers
  include CMS::EmailTemplate::MailerExtension

  def invitation(invitation)
    # TODO: subject and sender should be taken from invitating account.
    @invitation = invitation

    headers('Return-Path' => from_address(@invitation),
            'X-SMTPAPI' => '{"category": "Invitation"}')

    @name = @invitation.account.org_name.capitalize

    domain = if @invitation.account.provider?
               self.provider_account = @invitation.account
               provider.admin_domain
             else
               self.provider_account = @invitation.account.provider_account
               provider.domain
             end

    @url = invitee_signup_url(:invitation_token => @invitation.token,
                              :host => domain, :protocol => 'https')

    assign_drops :account => @invitation.account,
                 :provider => Liquid::Drops::Provider.new(self.provider_account),
                 :name    => Liquid::Drops::Deprecated.wrap(@name),
                 :url     => @url

    mail(:subject => "Invitation to join #{@invitation.account.org_name}",
         :to => @invitation.email,
         :from => from_address(@invitation),
         :template_name => 'invitation'
        )
  end

  private

  def from_address(user)
    user.account.provider_account.try(:from_email) || Rails.configuration.three_scale.noreply_email
  end
end
