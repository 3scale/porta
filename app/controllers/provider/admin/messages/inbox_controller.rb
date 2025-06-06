# frozen_string_literal: true

class Provider::Admin::Messages::InboxController < Provider::Admin::Messages::BaseController
  before_action :find_message, only: %i[show destroy reply mark_as_read]

  activate_menu :buyers, :messages, :inbox

  def index
    @messages = current_account.received_messages
                               .not_system
                               .latest_first
                               .paginate(pagination_params)
                               .decorate
  end

  def show
    @message.view! unless @message.read?
    @reply = @message.reply if @message.sender
  end

  def destroy
    @message.hide!

    redirect_to({ action: :index }, success: t('.success'))
  end

  def reply
    reply = @message.reply
    reply.attributes = message_params

    if reply.save && reply.deliver
      redirect_to({ action: :index }, success: t('.success'))
    else
      redirect_to provider_admin_messages_inbox_path(@message), danger: reply.errors.full_messages.to_sentence
    end
  end

  def mark_as_read
    @message.view! unless @message.read?
    respond_to :js
  end

  private

  def message_params
    params.fetch(:message).merge(:origin => "web")
  end

  def find_message
    @message = current_account.received_messages.find(params.require(:id)).decorate
  end

  def scope
    :received_messages
  end
end
