# frozen_string_literal: true

class SendUserInvitationWorker < ApplicationJob
  queue_as :default
  include Net

  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)

    mailer = invitation.account.provider? ? ProviderInvitationMailer : InvitationMailer
    mailer.invitation(invitation).deliver_now!

    invitation.update!(sent_at: Time.zone.now)
  rescue OpenSSL::SSL::SSLError, Net::SMTPError, SocketError, ActiveRecord::RecordNotFound => err
    logger.error(err.message)
  end
end
