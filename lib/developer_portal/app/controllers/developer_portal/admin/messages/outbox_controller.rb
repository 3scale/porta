# encoding: UTF-8
class DeveloperPortal::Admin::Messages::OutboxController < DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :build_message, :only => [:new, :create]
  activate_menu :dashboard, :messages

  liquify prefix: 'messages/outbox'

  def index
    messages   = current_account.messages.not_system.latest_first.paginate(page: message_params[:page])
    collection = Liquid::Drops::Collection.for_drop(Liquid::Drops::Message).new(messages)
    pagination = Liquid::Drops::Pagination.new(messages, self)

    assign_drops messages: collection, pagination: pagination
  end

  def show
    message = current_account.messages.find(message_params[:id])
    assign_drops message: Liquid::Drops:: Message.new(message)
  end

  def new
    @message.to current_account.provider_account
    assign_drops message: Liquid::Drops::Message.new(@message)
  end

  def destroy
    @message = current_account.messages.find(message_params[:id])
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to admin_messages_outbox_index_path
  end


  def create
    if @message.valid?
      enqueue_message
    else
      flash[:error] = 'Please fill subject.'
      redirect_to admin_messages_new_path
    end
  end

  private

  def enqueue_message
    @message.enqueue! :to => current_account.provider_account.id
    respond_to do |format|
      format.html do
        flash[:notice] = 'Message was sent.'
        redirect_to admin_messages_root_path
      end
      format.js
    end
  end

  def build_message
    @message = current_account.messages.build((message_params[:message] || {}).merge(:origin => "web"))
  end

  def message_params
    params.permit!.to_h
  end
end
