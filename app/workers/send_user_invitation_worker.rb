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

  DISCARD_ERRORS = [
    ActiveJob::DeserializationError
  ].freeze

  def perform(invitation)
    mailer = invitation.account.provider? ? ProviderInvitationMailer : InvitationMailer
    mailer.invitation(invitation).deliver_now!

    invitation.update(sent_at: Time.zone.now)
  rescue *DISCARD_ERRORS => ex
    Rails.logger.info "SphinxIndexationWorker#perform raised" #{ex.class} with message #{ex.message}"
  rescue *RETRY_ERRORS => e
    logger.error(e.message)
    retry_job
  end
end
