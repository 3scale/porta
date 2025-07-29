class Dashboard::ReceivedMessagesPresenter
  include ::Draper::ViewHelpers

  attr_reader :visible_messages, :unread_messages

  MAX_VISIBLE_MESSAGES = 100

  def initialize(visible_messages)
    @visible_messages = visible_messages.limit(MAX_VISIBLE_MESSAGES)
    @unread_messages = visible_messages.unread.limit(MAX_VISIBLE_MESSAGES)
  end

  def unread_exist?
    unread_messages.exists?
  end
end
