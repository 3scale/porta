# frozen_string_literal: true

class Provider::Admin::Messages::OutboxController < FrontendController
  activate_menu :buyers, :messages, :sent_messages

  delegate :messages, to: :current_account

  def new
    activate_menu :buyers, :messages, :inbox
    @message = messages.build({})
    @message.to recipients
  end

  def destroy
    @message = messages.find(message_id_param)
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to action: :index
  end

  def create
    @message = messages.build(message_params)
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
    @messages = current_account.messages
                               .not_system_for_provider
                               .latest_first
                               .paginate(pagination_params)
                               .decorate
  end

  def show
    @message = current_account.messages.find(message_id_param).decorate
  end

  private

  def recipients
    if mass_message?
      current_account.buyer_account_ids
    elsif current_account.provider?
      current_account.buyer_accounts.find(to_param)
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
    current_account.provider? && to_param.blank?
  end

  def message_params
    params.require(:message).permit(:subject, :body).merge(:origin => "web")
  end

  def message_id_param
    params.require(:id)
  end

  def pagination_params
    { page: params.permit(:page)[:page] }
  end

  def to_param
    params.permit(:to).fetch(:to)
  end
end
