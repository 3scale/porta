# encoding: UTF-8
class DeveloperPortal::Admin::Messages::OutboxController < DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  activate_menu :dashboard, :messages

  liquify prefix: 'messages/outbox'

  def index
    messages   = current_account.messages.not_system.latest_first.paginate(page: params[:page])
    collection = Liquid::Drops::Collection.for_drop(Liquid::Drops::Message).new(messages)
    pagination = Liquid::Drops::Pagination.new(messages, self)

    assign_drops messages: collection, pagination: pagination
  end

  def show
    message = current_account.messages.find(params[:id])
    assign_drops message: Liquid::Drops::Message.new(message)
  end

  def new
    @message = current_account.messages.build
    @message.to current_account.provider_account
    assign_drops message: Liquid::Drops::Message.new(@message)
  end

  def destroy
    @message = current_account.messages.find(params[:id])
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to admin_messages_outbox_index_path
  end

  def create
    @message = current_account.messages.build(**message_params, origin: "web")
    if @message.valid?
      enqueue_message_and_respond
    else
      flash[:error] = @message.errors.full_messages.to_sentence
      redirect_to admin_messages_new_path
    end
  end

  private

  def enqueue_message_and_respond
    @message.enqueue! :to => current_account.provider_account.id
    @notice = 'Message was sent.'
    respond_to do |format|
      format.html do
        flash[:notice] = @notice
        redirect_to admin_messages_root_path
      end
      format.js
    end
  end

  def message_params
    params.require(:message).permit(:subject, :body)
  end
end
