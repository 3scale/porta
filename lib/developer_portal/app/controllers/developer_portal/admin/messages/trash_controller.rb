class DeveloperPortal::Admin::Messages::TrashController < DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :find_message, :only => [:show, :destroy]
  activate_menu :dashboard, :messages

  liquify prefix: 'messages/trash'

  def index
    collection = current_account.trashed_messages.page(params[:page])
    # Transform deleted *received* messages to MessageRecipient instances
    mixed_collection = collection.map { |msg| msg.sender == current_account ? msg : msg.recipients.where(receiver: current_account) }
    messages = Liquid::Drops::Message.wrap(mixed_collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops messages: messages, pagination: pagination
  end

  def show
    assign_drops message: Liquid::Drops::Message.new(@message)
  end

  def destroy
    @message.restore_for!(current_account)

    flash[:notice] = 'Message was restored.'
    redirect_to admin_messages_trash_index_path
  end

  def empty
    current_account.hidden_messages.destroy_all

    flash[:notice] = 'Received messages have been deleted.'
    redirect_to admin_messages_trash_index_path
  end

  private

  def find_message
    @message = current_account.trashed_messages.find(params[:id])
  end
end
