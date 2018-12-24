require 'test_helper'

class DeveloperPortal::Admin::Messages::OutboxControllerTest < ActionDispatch::IntegrationTest
  include DeveloperPortal::Engine.routes.url_helpers

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @buyer    = FactoryBot.create(:buyer_account, provider_account: @provider)

    login_buyer @buyer

    host! @provider.domain
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
end
