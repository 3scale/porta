# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Dashboards::AudienceNavigationPresenterTest < ActiveSupport::TestCase
  Presenter = Provider::Admin::Dashboards::AudienceNavigationPresenter

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:admin, account: @provider)
    @presenter = Presenter.new(@user)
  end

  test 'link_to creates basic link with dashboard-navigation-link class' do
    link = @presenter.link_to(:message, '/path')
    assert_match(%r{class="dashboard-navigation-link" href="/path"}, link)
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

  test 'link_to merges custom classes with dashboard-navigation-link' do
    link = @presenter.link_to(:message, '/path', class: 'custom-class')
    assert_match(/class="dashboard-navigation-link custom-class"/, link)
  end

  test 'secondary_link_to wraps link with parenthesis and adds dashboard-navigation-secondary-link class' do
    link = @presenter.secondary_link_to(:message, '/path')
    assert_match(/^ \(.*class="dashboard-navigation-link dashboard-navigation-secondary-link".*\)$/m, link)
  end

  test 'secondary_link_to support custom classes' do
    link = @presenter.secondary_link_to(:message, '/path', class: 'custom-class')
    assert_match(/class="dashboard-navigation-link dashboard-navigation-secondary-link custom-class"/m, link)
  end

  test 'show unread_message when unread messages exist' do
    setup_messages_mocks(unread_count: 1, all_count: 50)

    presenter = Presenter.new(@user)

    assert_equal :unread_message, presenter.messages_name
    assert_equal 1, presenter.messages_count
  end

  test 'show all messages when no unread messages exist' do
    setup_messages_mocks(unread_count: 0, all_count: 50)

    presenter = Presenter.new(@user)

    assert_equal :message, presenter.messages_name
    assert_equal 50, presenter.messages_count
  end

  test 'messages_count caps at MESSAGES_QUERY_LIMIT when count reaches limit' do
    setup_messages_mocks(unread_count: Presenter::MESSAGES_QUERY_LIMIT)

    assert_equal Presenter::MESSAGES_QUERY_LIMIT, Presenter.new(@user).messages_count
  end

  test 'messages_limited? returns true when messages equal MESSAGES_QUERY_LIMIT' do
    setup_messages_mocks(unread_count: Presenter::MESSAGES_QUERY_LIMIT)

    assert Presenter.new(@user).messages_limited?
  end

  test 'messages_limited? returns false when messages do not reach MESSAGES_QUERY_LIMIT' do
    setup_messages_mocks(unread_count: 50)

    assert_not Presenter.new(@user).messages_limited?
  end

  private

  def setup_messages_mocks(unread_count:, all_count: nil)
    all_messages = mock('all_messages')
    all_messages_limited = mock('all_messages_limited')
    unread_messages = mock('unread_messages')
    unread_messages_limited = mock('unread_messages_limited')

    @provider.received_messages.stubs(:not_system).returns(all_messages)
    all_messages.stubs(:limit)
                .with(Presenter::MESSAGES_QUERY_LIMIT)
                .returns(all_messages_limited)
    all_messages.stubs(:unread).returns(unread_messages)
    unread_messages.stubs(:limit)
                   .with(Presenter::MESSAGES_QUERY_LIMIT)
                   .returns(unread_messages_limited)
    unread_messages_limited.stubs(:count).returns(unread_count)
    all_messages_limited.stubs(:count).returns(all_count) if all_count
  end
end
