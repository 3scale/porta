# frozen_string_literal: true

class SendUserInvitationWorker < ApplicationJob
  queue_as :default

  RETRY_ERRORS = [
    OpenSSL::SSL::SSLError,
    Net::SMTPAuthenticationError,
    Net::SMTPFatalError,
    Net::SMTPServerBusy,
    Net::SMTPSyntaxError,
    Net::SMTPUnknownError,
    Net::SMTPUnsupportedCommand,
    SocketError,
  ].freeze

  DISCARD_ERRORS = [
    ActiveRecord::RecordNotFound
  ].freeze

  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)

    mailer = invitation.account.provider? ? ProviderInvitationMailer : InvitationMailer
    mailer.invitation(invitation).deliver_now!

    invitation.update!(sent_at: Time.zone.now)
  rescue *RETRY_ERRORS => error
    logger.error(error.message)
  rescue *DISCARD_ERRORS => error
    logger.error(error.message)
    false
  end
end
