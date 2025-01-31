# frozen_string_literal: true

class Provider::Admin::Messages::OutboxController < Provider::Admin::Messages::BaseController
  activate_menu :buyers, :messages, :sent_messages

  delegate :messages, to: :current_account

  helper_method :modal?

  def new
    @message = build_message({})

    render partial: 'form' if modal?
  end

  def destroy
    @message = messages.find(message_id_param)
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to request.referer
  end

  def create
    @message = build_message(message_params)
    if @message.valid?
      enqueue_message_and_respond
    else
      respond_to do |format|
        format.html { render :new }
        format.js
      end
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

  def modal?
    @modal ||= request.xhr?
  end

  def build_message(params)
    message = messages.build(params)
    message.to recipients
    message
  end

  def enqueue_message_and_respond
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

  def recipients
    if mass_message?
      current_account.buyer_account_ids
    elsif current_account.provider?
      current_account.buyer_accounts.find(params.require(:to))
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
    params.require(:message).permit(:subject, :body).merge(:origin => "web")
  end

  def message_id_param
    params.require(:id)
  end

  def scope
    :messages
  end
end
