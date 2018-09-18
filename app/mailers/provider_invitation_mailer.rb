class ProviderInvitationMailer < ActionMailer::Base

  def invitation(invitation)
    # TODO: subject and sender should be taken from invitating account.
    @account = invitation.account
    @url = provider_invitee_signup_url(invitation_token: invitation.token,
                                       host: @account.admin_domain,
                                       protocol: 'https')

    headers('Return-Path' => @account.from_email,
            'X-SMTPAPI' => '{"category": "Invitation"}')

    mail(:subject => "Invitation to join #{invitation.account.org_name}",
         :to => invitation.email,
         :from => @account.from_email
        )
  end
end
