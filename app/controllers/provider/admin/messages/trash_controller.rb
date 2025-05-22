class Provider::Admin::Messages::TrashController < FrontendController
  before_action :find_message, only: [:show, :destroy]
  activate_menu :buyers, :messages, :trash
  helper_method :toolbar_props

  def index
    @messages = current_account.trashed_messages
                               .not_system
                               .latest_first
                               .paginate(pagination_params)
                               .decorate
  end

  def show
  end

  def destroy
    @message.restore_for!(current_account)

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
    @message = current_account.trashed_messages.not_system.find(params.require(:id)).decorate
  end

  def pagination_params
    { page: params[:page], per_page: params[:per_page] || 20 }
  end

  def toolbar_props
    {
      totalEntries: @messages.total_entries,
      pageEntries: @messages.length,
    }
  end
end
