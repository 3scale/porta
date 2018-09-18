class DeveloperPortal::Admin::Messages::TrashController < DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :find_message, :only => [:show, :destroy]
  activate_menu :dashboard, :messages

  liquify prefix: 'messages/trash'

  def index
    collection = current_account.hidden_messages.page(params[:page])
    messages = Liquid::Drops::Message.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops messages: messages, pagination: pagination
  end

  def show
    assign_drops message: Liquid::Drops::Message.new(@message)
  end

  def destroy
    @message.unhide!

    flash[:notice] = 'Message was restored.'
    redirect_to admin_messages_trash_index_path
  end

  def empty
    current_account.hidden_messages.destroy_all

    flash[:notice] = 'The trash was emptied.'
    redirect_to admin_messages_trash_index_path
  end

  private

  def find_message
    @message = current_account.hidden_messages.find(params[:id])
  end
end
