# frozen_string_literal: true

require 'test_helper'

class UtilizationTest < ActionDispatch::IntegrationTest
  include TestHelpers::BackendClientStubs

  setup do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    service = FactoryBot.create(:service, account: provider, name: "API1")
    plan = FactoryBot.create(:application_plan, issuer: service)
    @application = plan.create_contract_with(buyer)
    @metrics = FactoryBot.create_list(:metric, 4, service: service)

    host! provider.admin_domain
    provider_login_with provider.admins.first.username, 'supersecret'
  end

  teardown do
    @utilization = nil
  end

  test 'application is unmetered' do
    stub_backend_utilization([])
    stub_backend_get_keys

    get provider_admin_application_path(@application)
    assert_response :success

    assert_equal 1, utilization.size
    assert_equal 0, utilization.search("table").size
    assert_equal Nokogiri::XML::Text, utilization.children.first.class
  end

  test 'application has metrics' do
    data_full = [
      { period: 'day', metric: @metrics[0], max_value: 5000, current_value: 6000 },
      { period: 'year', metric: @metrics[1], max_value: 10000, current_value: 9000 },
      { period: 'minute', metric: @metrics[2], max_value: 666, current_value: 0},
      { period: 'minute', metric: @metrics[3], max_value: 0, current_value: 0},
    ].map { |attr| UtilizationRecord.new(attr) }

    stub_backend_utilization(data_full)
    stub_backend_get_keys

    get provider_admin_application_path(@application)
    assert_response :success

    assert_equal 1, utilization.size

    table = utilization.search("table[@class='data']")
    assert_equal 1, table.size
    assert_equal 1*2, table.search("td[@class='above-100']").size
    assert_equal 1*2, table.search("td[@class='above-80']").size
    assert_equal 2*2, table.search("td[@class='above-0']").size
    assert_equal 0*2, table.search("td[@class='infinity']").size
  end

  test 'application has metrics with one disabled over the limit' do
    data_infinity = [
      { period: 'day', metric: @metrics[0], max_value: 5000, current_value: 4010 },
      { period: 'year', metric: @metrics[1], max_value: 10000, current_value: 4000 },
      { period: 'minute', metric: @metrics[2], max_value: 666, current_value: 0},
      { period: 'minute', metric: @metrics[3], max_value: 0, current_value: 6},
    ].map { |attr| UtilizationRecord.new(attr) }
    stub_backend_utilization(data_infinity)
    stub_backend_get_keys

    get provider_admin_application_path(@application)
    assert_response :success

    assert_equal 1, utilization.size

    table = utilization.search("table[@class='data']")
    assert_equal 1, table.size
    assert_equal 0*2, table.search("td[@class='above-100']").size
    assert_equal 1*2, table.search("td[@class='above-80']").size
    assert_equal 2*2, table.search("td[@class='above-0']").size
    assert_equal 1*2, table.search("td[@class='infinity']").size
  end

  private

  def utilization
    @utilization ||= Nokogiri::XML.parse(body).search("div[@id='application-utilization']")
  end
end
