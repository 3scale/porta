# frozen_string_literal: true

class Provider::Admin::Messages::OutboxController < FrontendController
  before_action :build_message, :only => %i[new create]
  activate_menu :buyers, :messages, :sent_messages

  def new
    activate_menu :buyers, :messages, :inbox
    @message.to recipients
  end

  def destroy
    @message = current_account.messages.find(permitted_params[:id])
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
    @messages = current_account.messages.not_system_for_provider.latest_first.paginate(page: permitted_params[:page]).decorate
  end

  def show
    @message = current_account.messages.find(permitted_params[:id]).decorate
  end

  private

  PERMITTED_PARAMS = [:id, :to, :page, { message: %i[subject body origin] }].freeze

  def build_message
    @message = current_account.messages.build(message_params)
  end

  def recipients
    if mass_message?
      current_account.buyer_account_ids
    elsif current_account.provider?
      current_account.buyer_accounts.find(permitted_params[:to])
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
    current_account.provider? && permitted_params[:to].blank?
  end

  def message_params
    permitted_params.fetch(:message, {}).merge(:origin => "web")
  end

  def permitted_params
    params.permit(PERMITTED_PARAMS)
  end
end
