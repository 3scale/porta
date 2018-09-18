class Dashboard::UnreadMessagesPresenter
  include ::Draper::ViewHelpers

  attr_reader :visible_messages

  MAX_VISIBLE_MESSAGES = 100

  def initialize(visible_messages)
    @visible_messages = visible_messages
  end

  def show_counter?
    unread_messages.exists? && visible_messages.size < MAX_VISIBLE_MESSAGES
  end

  def unread_messages_size
    h.number_to_human(unread_messages.size)
  end

  private

  def unread_messages
    @unread_messages ||= visible_messages.unread
  end
end
