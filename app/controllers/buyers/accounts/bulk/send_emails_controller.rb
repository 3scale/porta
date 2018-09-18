class Buyers::Accounts::Bulk::SendEmailsController < Buyers::Accounts::Bulk::BaseController

  def new
  end

  def create
    @errors = []

    @accounts.each do |recipient|
      message = current_account.messages.build params[:send_emails]
      message.to = recipient
      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

end
