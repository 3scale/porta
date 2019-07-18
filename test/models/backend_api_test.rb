require 'test_helper'

class BackendApiTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
    @backend_api = BackendApi.new(account: @account, name: 'My Backend API')
  end

  def test_default_api_backend
    assert_equal "https://echo-api.3scale.net:443", @backend_api.default_api_backend
    assert_equal "https://echo-api.3scale.net:443", BackendApi.default_api_backend
  end

  test 'proxy api backend with base path' do
    @account.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @account.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(false)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    @backend_api.valid?
    assert_equal [@backend_api.errors.generate_message(:private_endpoint, :invalid)], @backend_api.errors.messages[:private_endpoint]

    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(true)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    assert @backend_api.valid?
  end

  test 'gather methods and metrics from all services of the account' do
    first_service = FactoryBot.create(:simple_service, account: @account)
    FactoryBot.create_list(:metric, 2, service: first_service, parent: first_service.metrics.hits) # 2 methods of 1st service's Hits metric

    second_service = FactoryBot.create(:simple_service, account: @account)
    FactoryBot.create(:metric, service: second_service, system_name: 'ads', friendly_name: 'Ads') # another top level metric of the new service

    assert_equal 5, @backend_api.metrics.count
    assert_equal 3, @backend_api.top_level_metrics.count
    assert_equal 2, @backend_api.method_metrics.count

    assert_same_elements @account.metrics.ids, @backend_api.metrics.ids
    assert_same_elements @account.top_level_metrics.ids, @backend_api.top_level_metrics.ids
    assert_same_elements @account.metrics.where.not(parent_id: nil).ids, @backend_api.method_metrics.ids
  end

  test 'gather mapping rules from all proxies of the account' do
    first_service = FactoryBot.create(:service, account: @account)
    FactoryBot.create_list(:proxy_rule, 2, proxy: first_service.proxy) # 2 more mapping rules to the first proxy/service

    second_service = FactoryBot.create(:service, account: @account)
    FactoryBot.create(:proxy_rule, proxy: second_service.proxy) # another extra mapping rule of a different proxy/service

    assert_equal 5, @backend_api.mapping_rules.count
    assert_same_elements @account.proxy_rules.ids, @backend_api.proxy_rules.ids
    assert_equal @backend_api.method(:mapping_rules), @backend_api.method(:proxy_rules)
  end
end
