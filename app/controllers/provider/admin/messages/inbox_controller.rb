class Provider::Admin::Messages::InboxController < FrontendController
  before_action :find_message, :only => [:show, :destroy, :reply]
  activate_menu :buyers, :messages, :inbox

  def index
    @messages = current_account.received_messages.not_system.latest_first.paginate(page: params[:page]).decorate
  end

  def show
    @message.view! unless @message.read?
    @reply = @message.reply if @message.sender
  end

  def destroy
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to action: :index
  end

  def reply
    reply = @message.reply
    reply.attributes = message_params

    if reply.valid?
      send_reply(reply)
    else
      flash[:error] = reply.errors.full_messages.to_sentence
      redirect_to provider_admin_messages_inbox_path(@message)
    end
  end

  private

  def message_params
    params.fetch(:message).merge(:origin => "web")
  end

  def find_message
    @message = current_account.received_messages.find(params.require(:id)).decorate
  end

  def send_reply(reply)
    reply.save
    reply.deliver

    flash[:notice] = 'Reply was sent.'
    redirect_to action: :index
  end
end
