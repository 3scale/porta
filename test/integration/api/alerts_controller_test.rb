# frozen_string_literal: true

require 'test_helper'

class Api::AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    login! @provider
  end

  attr_reader :provider

  test 'get index contains the proper urls of the cinstances' do
    alert_limit_collection = FactoryBot.create_list(:limit_alert, 2, account: provider)
    get admin_alerts_path
    assert_response :ok
    alert_limit_collection.each do |alert_limit|
      cinstance = alert_limit.cinstance
      assert_xpath("//a[contains(@href, '#{provider_admin_application_path(cinstance)}')]", cinstance.name)
    end
  end

  test 'get index should filter by account_id, cinstance_id and fulltext' do
    buyer1, buyer2 = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider)
    plan = FactoryBot.create(:simple_application_plan, issuer: provider.default_service)
    cinstance1, cinstance2 = [buyer1, buyer2].map { |buyer| FactoryBot.create(:simple_cinstance, plan: plan, user_account: buyer) }
    [cinstance1, cinstance2].each { |cinstance|FactoryBot.create(:limit_alert, account: provider, cinstance: cinstance) }

    get admin_alerts_path
    assert_equal 2, assigns(:alerts).count

    get admin_alerts_path, params: { account_id: buyer1.id }

    alerts = assigns(:alerts)
    assert_equal 1, alerts.count
    assert_equal buyer1, alerts.first.cinstance.buyer_account

    get admin_alerts_path, params: { cinstance_id: cinstance2.id }

    alerts = assigns(:alerts)
    assert_equal 1, alerts.count
    assert_equal cinstance2, alerts.first.cinstance

    Account.expects(:search_ids).with(buyer1.name).returns([buyer1.id])

    get admin_alerts_path, params: { search: {account: { query: buyer1.name} } }

    alerts = assigns(:alerts)
    assert_equal 1, alerts.count
    assert_equal buyer1, alerts.first.cinstance.buyer_account
  end
end
