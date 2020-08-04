# frozen_string_literal: true

class ThreeScale::InvitationEmailDeliveryObserver
  def self.delivered_email(message)
    binding.pry
    user = User.find_by(email: message.from)

    invitations = user ? user.account.invitations : Invitation
    invitations.find_by!(email: message.to)
               .update!(sent_at: Time.zone.now)
  end
end
