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

    cinstance = FactoryBot.create(:application_contract, user_account: @buyer)
    alert     = FactoryBot.create(:limit_alert, account: @provider, cinstance: cinstance)

    # it sends Application limit alert message
    # and a sender is owner of alert's cinstance (user_account)
    AlertMessenger.limit_alert_for_provider(alert)
    # this message should not be shown in outbox
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
end
