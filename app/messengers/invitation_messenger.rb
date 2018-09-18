class InvitationMessenger < Messenger::Base

  def invite(invitation)
    domain = if invitation.account.provider?
               invitation.account.admin_domain
             else
               invitation.account.provider_account.domain
             end
    @url = invitee_signup_url(:invitation_token => invitation.token,
                              :host => domain)

    message(:sender           => Rails.configuration.three_scale.noreply_email,
            :to               => invitation.email,
            :subject          => "Invitation to join #{invitation.account.org_name.capitalize}",
            :system_operation => nil)

  end

end
