# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::DashboardNavigationPresenterTest < ActiveSupport::TestCase
  Presenter = Provider::Admin::DashboardNavigationPresenter

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:admin, account: @provider)
    @presenter = Presenter.new(@user)
  end

  test 'initializes with user' do
    assert_instance_of Presenter, @presenter
  end

  test 'link_to creates basic link with DashboardNavigation-link class' do
    link = @presenter.link_to(:message, '/path')
    assert_match(%r{class="DashboardNavigation-link" href="/path"}, link)
  end

  test 'link_to includes count when provided' do
    link = @presenter.link_to(:message, '/path', count: 5)
    assert_match(/5 Messages/m, link)
  end

  test 'link_to adds plus sign when limited option is true' do
    link = @presenter.link_to(:message, '/path', count: 100, limited: true)
    assert_match(/100\+ Messages/, link)
  end

  test 'link_to uses number_to_human for large counts' do
    link = @presenter.link_to(:message, '/path', count: 1500)
    assert_match(/1\.5K Messages/, link)
  end

  test 'link_to merges custom classes with DashboardNavigation-link' do
    link = @presenter.link_to(:message, '/path', class: 'custom-class')
    assert_match(/class="DashboardNavigation-link custom-class"/, link)
  end

  test 'secondary_link_to wraps link with parenthesis and adds DashboardNavigation-link-secondary class' do
    link = @presenter.secondary_link_to(:message, '/path')
    assert_match(/^ \(.*class="DashboardNavigation-link DashboardNavigation-link-secondary".*\)$/m, link)
  end

  test 'secondary_link_to support custom classes' do
    link = @presenter.secondary_link_to(:message, '/path', class: 'custom-class')
    assert_match(/class="DashboardNavigation-link DashboardNavigation-link-secondary custom-class"/m, link)
  end

  test 'show unread_message when unread messages exist' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:count).returns(1)
    all_messages.stubs(:count).returns(200)

    presenter = Presenter.new(@user)

    assert_equal :unread_message, presenter.messages_name
    assert_equal 1, presenter.messages_count
  end

  test 'show all messages when no unread messages exist' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    all_messages.stubs(:count).returns(50)
    unread_messages.stubs(:count).returns(0)

    presenter = Presenter.new(@user)

    assert_equal :message, presenter.messages_name
    assert_equal 50, presenter.messages_count
  end

  test 'messages_count caps at MAX_VISIBLE_MESSAGES when count exceeds limit' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:count).returns(9999)

    assert_equal Presenter::MAX_VISIBLE_MESSAGES, Presenter.new(@user).messages_count
  end

  test 'messages_limited? returns true when messages exceed MAX_VISIBLE_MESSAGES' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:count).returns(150)

    assert Presenter.new(@user).messages_limited?
  end

  test 'messages_limited? returns false when messages do not exceed MAX_VISIBLE_MESSAGES' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:count).returns(50)

    assert_not Presenter.new(@user).messages_limited?
  end

  test 'messages_limited? returns false when messages equal MAX_VISIBLE_MESSAGES' do
    all_messages = mock('all_messages')
    unread_messages = mock('unread_messages')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:count).returns(100)

    assert_not Presenter.new(@user).messages_limited?
  end
end
