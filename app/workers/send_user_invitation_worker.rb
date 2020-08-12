# frozen_string_literal: true

class SendUserInvitationWorker < ApplicationJob
  queue_as :default

  ERRORS = [
    OpenSSL::SSL::SSLError,
    Net::SMTPAuthenticationError,
    Net::SMTPFatalError,
    Net::SMTPServerBusy,
    Net::SMTPSyntaxError,
    Net::SMTPUnknownError,
    Net::SMTPUnsupportedCommand,
    SocketError
  ].freeze

  def perform(invitation)
    mailer = invitation.account.provider? ? ProviderInvitationMailer : InvitationMailer
    mailer.invitation(invitation).deliver_now!

    invitation.update(sent_at: Time.zone.now)
  rescue *ERRORS => e
    logger.error(e.message)
    retry_job
  end
end
