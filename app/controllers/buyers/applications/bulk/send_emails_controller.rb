class Buyers::Applications::Bulk::SendEmailsController < Buyers::Applications::Bulk::BaseController

  def new
  end

  def create
    @recipients = @applications.map(&:user_account)

    @errors = []
    @recipients.each do |recipient|
      message = current_account.messages.build params[:send_emails]
      message.to = recipient

      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

end
