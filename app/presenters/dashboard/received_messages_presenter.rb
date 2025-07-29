class Dashboard::ReceivedMessagesPresenter
  include ::Draper::ViewHelpers

  attr_reader :visible_messages, :unread_messages

  MAX_VISIBLE_MESSAGES = 100

  def initialize(visible_messages)
    @visible_messages = visible_messages.limit(MAX_VISIBLE_MESSAGES)
    @unread_messages = visible_messages.unread.limit(MAX_VISIBLE_MESSAGES)
  end

  def show_counter?
    unread_messages.exists? && visible_messages.size < MAX_VISIBLE_MESSAGES
  end

  def unread_messages_size
    h.number_to_human(unread_messages.size)
  end
end
