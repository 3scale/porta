# frozen_string_literal: true

# TODO: remove and use invitations index presenter
module InvitationsHelper
  def invitation_sent_date(invitation)
    invitation.sent_at&.to_s(:long) || 'Not sent yet'
  end

  def invitation_status(invitation)
    if invitation.accepted?
      "yes, on #{invitation.accepted_at.to_s(:short)}"
    else
      "no"
    end
  end
end
