# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class ReceivedMessagesPresenterTest < ActiveSupport::TestCase

    Presenter = ReceivedMessagesPresenter

    def setup
      @unread_messages = Object.new
      @unread_messages.stubs(:limit).returns(@unread_messages)
      @visible_messages = Object.new
      @visible_messages.stubs(:limit).returns(@visible_messages)
      @visible_messages.stubs(:unread).returns(@unread_messages)
    end

    def test_unread_exist
      @unread_messages.stubs(:exists?).returns(false)
      presenter = Presenter.new(@visible_messages)
      assert_not presenter.unread_exist?

      @unread_messages.stubs(:exists?).returns(true)
      presenter = Presenter.new(@visible_messages)
      assert presenter.unread_exist?
    end
  end
end
