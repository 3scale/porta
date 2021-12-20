# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::SendEmailsController < Buyers::ServiceContracts::Bulk::BaseController
  def create
    recipients.each do |recipient|
      message = current_account.messages.build send_email_params
      message.to = recipient

      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

  private

  def send_email_params
    params.require(:send_emails).permit(:subject, :body)
  end

  def recipients
    @recipients ||= @service_contracts.map(&:user_account)
  end
end
