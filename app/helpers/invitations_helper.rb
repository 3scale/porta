module InvitationsHelper
  def invitation_sent_date(invitation)
    (invitation.sent_at.presence || invitation.created_at).to_s(:long)
  end

  def invitation_status(invitation)
    if invitation.accepted?
      "yes, on #{invitation.accepted_at.to_s(:short)}"
    else
      "no"
    end
  end

  def button_to_resend_buyer_invitation(invitation)
    fancy_link_to('Resend', resend_provider_admin_account_invitation_path(invitation.account,invitation),
                            { :id => "resend-invitation-#{invitation.id}", :method => :put })
  end
end
