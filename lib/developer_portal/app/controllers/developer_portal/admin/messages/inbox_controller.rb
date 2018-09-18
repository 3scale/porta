class DeveloperPortal::Admin::Messages::InboxController < ::DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :find_message, only: [:show, :destroy, :reply ]
  activate_menu :dashboard, :messages

  liquify prefix: 'messages/inbox'

  def index
    messages = current_account.received_messages.order('created_at DESC').paginate(page: params[:page])

    collection = Liquid::Drops::Collection.for_drop(Liquid::Drops::Message).new(messages)
    pagination = Liquid::Drops::Pagination.new(messages, self)

    assign_drops messages: collection, pagination: pagination

  end

  def show
    drops = {}
    @message.view! unless @message.read?
    drops[:message] = Liquid::Drops::Message.new(@message)

    if @message.sender
      reply = @message.reply
      drops[:reply] = Liquid::Drops::Message.new(reply)
    end

    assign_drops drops
  end

  def destroy
    @message.hide!

    flash[:notice] = 'Message was deleted.'
    redirect_to admin_messages_root_path
  end

  def create
    @message = current_account.received_messages.find(params[:reply_to])
    reply = @message.reply
    reply.attributes = params[:message].merge(origin: "web")

    reply.save!
    reply.deliver!

    flash[:notice] = 'Reply was sent.'
    redirect_to admin_messages_root_path
  end

  private

  def find_message
    @message = current_account.received_messages.find(params[:id])
  end
end
