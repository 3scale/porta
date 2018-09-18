class Buyers::ServiceContracts::Bulk::SendEmailsController < Buyers::ServiceContracts::Bulk::BaseController

  def new
  end

  def create
    @recipients = @service_contracts.map(&:user_account)

    @errors = []
    @recipients.each do |recipient|
      message = current_account.messages.build params[:send_emails]
      message.to = recipient

      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

end
