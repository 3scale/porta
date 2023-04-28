class Admin::Api::MessagesController < Admin::Api::BuyersBaseController
  wrap_parameters ::Message
  representer ::Message

  # Account Message
  # POST /admin/api/accounts/{account_id}/messages.xml
  def create
    message = current_account.messages.build params[:message].permit(:body, :subject)
    message.to = buyer
    message.deliver!

    respond_with message
  end
end
