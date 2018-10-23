class Provider::Admin::Messages::OutboxController < FrontendController
  before_action :build_message, :only => [:new, :create]
  activate_menu :buyers, :messages, :sent_messages

  def new
    activate_menu :buyers, :messages, :inbox
    @message.to recipients
  end

  def destroy
    @message = current_account.messages.find(params[:id])
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to action: :index
  end


  def create
    @message.enqueue! :to => recipient_ids

    @notice = 'Message was sent.'

    respond_to do |format|
      format.html do
        flash[:notice] = @notice
        redirect_to provider_admin_messages_root_path
      end

      format.js
    end
  end

  def index
    @messages = current_account.messages.not_system_for_provider.latest_first.paginate(page: params[:page])
  end

  def show
    @message = current_account.messages.find(params[:id])
  end

  private

  def build_message
    @message = current_account.messages.build(message_params)
  end

  def recipients
    if mass_message?
      current_account.buyer_account_ids
    elsif current_account.provider?
      current_account.buyer_accounts.find(params[:to])
    else
      current_account.provider_account
    end
  end

  def recipient_ids
    if mass_message?
      recipients
    else
      recipients.id
    end
  end

  def mass_message?
    current_account.provider? && params[:to].blank?
  end

  def message_params
    params.fetch(:message, {}).merge(:origin => "web")
  end
end
