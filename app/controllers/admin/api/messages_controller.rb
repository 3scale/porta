class Admin::Api::MessagesController < Admin::Api::BuyersBaseController
  wrap_parameters ::Message
  representer ::Message

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path        = "/admin/api/accounts/{account_id}/messages.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Account Message"
  ##~ op.description = "Sends a message to the account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add :name => "body", :description => "Text to send", :dataType => "string", :required => true, :paramType => "query", :allowMultiple => false
  #
  def create
    message = current_account.messages.build params[:message].permit(:body)
    message.to = buyer
    message.deliver!

    respond_with message
  end
end
