require 'test_helper'

class DeveloperPortal::Admin::Messages::OutboxControllerIntegrationTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    @buyer    = FactoryBot.create(:buyer_account)
    @provider = @buyer.provider_account

    login_buyer @buyer

    host! @provider.internal_domain
  end

  def test_index
    get admin_messages_outbox_index_path
    assert_equal [], assigns['_assigned_drops']['messages']

    FactoryBot.create(:message, sender: @buyer)
    get admin_messages_outbox_index_path
    assert_not_equal [], assigns['_assigned_drops']['messages']
  end

  def test_show
    sent_message = FactoryBot.create(:message, sender: @buyer)
    get admin_messages_outbox_path(sent_message)

    assert_equal sent_message.id, assigns(:_assigned_drops)['message'].id
  end

  def test_new
    get admin_messages_new_path
    assert_response :success

    assigned_message = assigns(:_assigned_drops)['message']
    assert_not_nil assigned_message
    assert_equal @buyer.name, assigned_message.sender
    assert_equal @provider.org_name, assigned_message.to
  end

  def test_destroy
    sent_message = FactoryBot.create(:message, sender: @buyer)
    assert_not sent_message.hidden?

    delete admin_messages_outbox_path(sent_message)

    assert_response :redirect
    assert_redirected_to admin_messages_outbox_index_path
    assert_equal 'Message was deleted.', flash[:notice]
    assert sent_message.reload.hidden?
  end

  def test_create_with_valid_message
    assert_difference 'Message.count', 0 do # Message created after worker processes
      post admin_messages_outbox_index_path, params: {
        message: { subject: 'Test Subject', body: 'Test Body' }
      }
    end

    assert_response :redirect
    assert_redirected_to admin_messages_root_path
    assert_equal 'Message was sent.', flash[:notice]

    # Process the message worker
    MessageWorker.drain

    message = Message.last
    assert_not_nil message
    assert_equal 'Test Subject', message.subject
    assert_equal 'Test Body', message.body
    assert_equal 'web', message.origin
    assert_equal @buyer, message.sender
  end

  def test_create_with_invalid_message
    assert_no_difference 'Message.count' do
      post admin_messages_outbox_index_path, params: {
        message: { subject: '', body: 'Body without subject' }
      }
    end

    assert_response :redirect
    assert_redirected_to admin_messages_new_path
    assert_not_nil flash[:error]
    assert_match(/subject/i, flash[:error])

    MessageWorker.drain
    assert_nil Message.last
  end
end
