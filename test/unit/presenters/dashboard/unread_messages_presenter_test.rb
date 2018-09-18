require 'test_helper'

class UnreadMessagesPresenterTest < Draper::TestCase

  Presenter = Dashboard::UnreadMessagesPresenter

  class MessagesDouble
    attr_reader :size

    def initialize(size = 0)
      @size = size
    end

    def exists?
      !size.zero?
    end
  end

  def test_show_counter
    unread_messages  = MessagesDouble.new()
    visible_messages = MessagesDouble.new()
    visible_messages.expects(:unread).returns(unread_messages)
    presenter = Presenter.new(visible_messages)
    refute presenter.show_counter?

    unread_messages  = MessagesDouble.new(1)
    visible_messages = MessagesDouble.new(Presenter::MAX_VISIBLE_MESSAGES - 1)
    visible_messages.expects(:unread).returns(unread_messages)
    presenter = Presenter.new(visible_messages)
    assert presenter.show_counter?

    unread_messages  = MessagesDouble.new(1)
    visible_messages = MessagesDouble.new(Presenter::MAX_VISIBLE_MESSAGES + 1)
    visible_messages.expects(:unread).returns(unread_messages)
    presenter = Presenter.new(visible_messages)
    refute presenter.show_counter?
  end

  def test_unread_messages_size
    unread_messages = MessagesDouble.new(101)
    presenter = Presenter.new([])
    presenter.expects(:unread_messages).returns(unread_messages)
    assert_match '101', presenter.unread_messages_size
  end
end
