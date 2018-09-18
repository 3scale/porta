class Provider::Admin::Messages::TrashController < FrontendController
  before_action :find_message, only: [:show, :destroy]
  activate_menu :buyers, :messages

  def index
    @messages = current_account.trashed_messages
                               .not_system.latest_first.paginate(page: params[:page])
  end

  def show
  end

  def destroy
    @message.unhide!

    flash[:notice] = 'Message was restored.'
    redirect_to action: :index
  end

  def empty
    ::Messages::DestroyAllService.run!(account:           current_account,
                                       association_class: MessageRecipient,
                                       scope:             :hidden)

    flash[:notice] = 'The trash was emptied.'
    redirect_to action: :index
  end

  private

  def find_message
    @message = current_account.hidden_messages.find(params[:id])
  end
end
