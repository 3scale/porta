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

  test 'gather methods and metrics from all services using the backend' do
    services_using_backend = FactoryBot.create_list(:simple_service, 2, account: @account)
    service_not_using_backend = FactoryBot.create(:simple_service, account: @account) # service of the same account not using the backend

    create_metrics_for = ->(service, quantity = 1, attributes = {}) do
      FactoryBot.create_list(:metric, quantity, attributes.merge(service: service))
      FactoryBot.create(:backend_api_config, service: service, backend_api: @backend_api)
    end

    create_metrics_for.call(services_using_backend.first, 2, parent: services_using_backend.first.metrics.hits) # 2 methods of 1st service's Hits metric
    create_metrics_for.call(services_using_backend.last,  1, system_name: 'ads', friendly_name: 'Ads') # 2 methods of 1st service's Hits metric

    assert_equal 5, @backend_api.metrics.count
    assert_equal 3, @backend_api.top_level_metrics.count
    assert_equal 2, @backend_api.method_metrics.count

    metrics_in_backend = @account.metrics.where(service: services_using_backend)
    top_level_metrics_in_backend = metrics_in_backend.where(parent_id: nil)
    methods_in_backend = metrics_in_backend.where.not(parent_id: nil)

    assert_same_elements metrics_in_backend, @backend_api.metrics
    assert_same_elements top_level_metrics_in_backend, @backend_api.top_level_metrics
    assert_same_elements methods_in_backend.where.not(parent_id: nil), @backend_api.method_metrics
    assert_not_includes @backend_api.metrics, service_not_using_backend.metrics.hits
  end

  test 'gather mapping rules from all proxies of services using the backend' do
    services_using_backend = FactoryBot.create_list(:simple_service, 2, account: @account)
    service_not_using_backend = FactoryBot.create(:simple_service, account: @account) # service of the same account not using the backend

    create_rules_for = ->(service, quantity = 1) do
      FactoryBot.create_list(:proxy_rule, quantity, proxy: service.proxy)
      FactoryBot.create(:backend_api_config, service: service, backend_api: @backend_api)
    end

    create_rules_for.call(services_using_backend.first, 2) # 2 more mapping rules to the first proxy/service
    create_rules_for.call(services_using_backend.last) # another extra mapping rule of a different proxy/service

    assert_equal 5, @backend_api.mapping_rules.count

    proxy_rules_in_backend = @account.proxy_rules.where(proxies: { service_id: services_using_backend.map(&:id) })
    proxy_rules_not_in_backend = service_not_using_backend.proxy.proxy_rules

    assert_same_elements proxy_rules_in_backend, @backend_api.proxy_rules
    assert_not_includes @backend_api.proxy_rules, proxy_rules_not_in_backend
  end
end
