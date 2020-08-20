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
    SocketError
  ].freeze

  rescue_from ActiveJob::DeserializationError do |e|
    logger.error("SendUserInvitationWorker#perform raised #{e.class} with message #{e.message}")
  end

  def perform(invitation)
    mailer = invitation.account.provider? ? ProviderInvitationMailer : InvitationMailer
    mailer.invitation(invitation).deliver_now!

    invitation.update(sent_at: Time.zone.now)
  rescue *RETRY_ERRORS => e
    logger.error("SendUserInvitationWorker#perform raised #{e.class} with message #{e.message}")
    retry_job
  end
end
