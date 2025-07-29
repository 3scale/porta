require 'test_helper'

class UnreadMessagesPresenterTest < Draper::TestCase

  Presenter = Dashboard::ReceivedMessagesPresenter

  def setup
    @unread_messages = Object.new
    @unread_messages.stubs(:limit).returns(@unread_messages)
    @visible_messages = Object.new
    @visible_messages.stubs(:limit).returns(@visible_messages)
    @visible_messages.stubs(:unread).returns(@unread_messages)
  end

  def test_show_counter
    @unread_messages.stubs(:exists?).returns(false)
    presenter = Presenter.new(@visible_messages)
    assert_not presenter.show_counter?

    @visible_messages.stubs(:size).returns(Presenter::MAX_VISIBLE_MESSAGES + 1)
    presenter = Presenter.new(@visible_messages)
    assert_not presenter.show_counter?

    @unread_messages.stubs(:exists?).returns(true)
    @visible_messages.stubs(:size).returns(Presenter::MAX_VISIBLE_MESSAGES - 1)
    presenter = Presenter.new(@visible_messages)
    assert presenter.show_counter?
  end

  def test_unread_messages_size
    @unread_messages.stubs(:exists?).returns(true)
    @unread_messages.stubs(:size).returns(50)
    @visible_messages.stubs(:size).returns(75)
    presenter = Presenter.new(@visible_messages)
    assert_match '50', presenter.unread_messages_size
  end
end
