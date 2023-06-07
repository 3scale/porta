# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Messages::TrashControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)

    @provider_sent_message = FactoryBot.create(:message, sender: provider, state: 'sent')
    @buyer_received_message = FactoryBot.create(:received_message, message: provider_sent_message, receiver: buyer)

    @buyer_sent_message = FactoryBot.create(:message, sender: buyer, state: 'sent')
    @provider_received_message = FactoryBot.create(:received_message, message: buyer_sent_message, receiver: provider)

    [provider_sent_message, provider_received_message].each(&:hide!)
    login! provider
  end

  attr_reader :provider, :buyer, :provider_sent_message, :buyer_sent_message, :buyer_received_message, :provider_received_message

  test 'index' do
    get provider_admin_messages_trash_index_path
    assert_response :success
    assert_equal 2, assigns(:messages).count
  end

  test 'index of deleted messages' do
    provider_received_message.update deleted_at: DateTime.new(2015, 11, 11)
    get provider_admin_messages_trash_index_path
    assert_response :success
    assert_equal 1, assigns(:messages).count
  end

  test 'show' do
    get provider_admin_messages_trash_path(provider_sent_message)
    assert_response :success
  end

  test 'show deleted message' do
    get provider_admin_messages_trash_path(buyer_sent_message)
    assert_response :success

    provider_received_message.update deleted_at: DateTime.new(2015, 11, 11)
    get provider_admin_messages_trash_path(buyer_sent_message)
    assert_response :not_found
  end

  test 'destroy' do
    assert provider_sent_message.hidden?
    delete provider_admin_messages_trash_path(provider_sent_message)
    assert_response :redirect
    assert_equal 'Message was restored.', flash[:notice]
    refute provider_sent_message.reload.hidden?
  end

  test 'empty' do
    assert_equal 2, provider.trashed_messages.count
    delete empty_provider_admin_messages_trash_index_path
    assert_response :redirect
    assert_equal 'The trash was emptied.', flash[:notice]
    assert_equal 1, provider.trashed_messages.count # only trashed messages received by the provider are emptied
  end
end
