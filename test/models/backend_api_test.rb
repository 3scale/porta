require 'test_helper'

class BackendApiTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
    @backend_api = BackendApi.new(account: @account, name: 'My Backend API')
  end

  def test_oldest_first
    FactoryBot.create_list(:backend_api, 3)
    BackendApi.all.each_with_index { |backend_api, index| backend_api.update_column(:created_at, Date.today - (index + 1).days) }
    assert_equal BackendApi.order(created_at: :asc).pluck(:id), BackendApi.oldest_first.pluck(:id)
  end

  def test_default_api_backend
    assert_equal "https://echo-api.3scale.net:443", @backend_api.default_api_backend
    assert_equal "https://echo-api.3scale.net:443", BackendApi.default_api_backend
  end

  test 'proxy api backend with base path' do
    @account.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @account.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(false)
    @account.expects(:provider_can_use?).with(:api_as_product).at_least_once.returns(false)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    @backend_api.valid?
    assert_equal [@backend_api.errors.generate_message(:private_endpoint, :invalid)], @backend_api.errors.messages[:private_endpoint]

    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(true)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    assert @backend_api.valid?
  end

  test '.orphans should return backend apis that do not belongs to any service' do
    account = FactoryBot.create(:account)
    FactoryBot.create(:service, account: account)
    service_to_delete = FactoryBot.create(:simple_service, :with_default_backend_api, system_name: 'orphan_system', account: account)
    orphan_backend_api = service_to_delete.backend_api_configs.first.backend_api

    assert_equal [], BackendApi.orphans

    service_to_delete.destroy!

    assert_equal [orphan_backend_api], BackendApi.orphans
  end

  test '.of_product returns the backend apis that are associated to that product' do
    # service 1 <-> 1 backend api
    # service 2 <-> 1 backend api
    # service 1 <-> 2 backend api
    # service 1 <-> 0 backend api
    account = FactoryBot.create(:simple_provider)
    services = FactoryBot.create_list(:service, 5, account: account)
    backend_apis = FactoryBot.create_list(:backend_api, 4, account: account)
    FactoryBot.create(:backend_api_config, service: services[0], backend_api: backend_apis[0])
    FactoryBot.create(:backend_api_config, service: services[1], backend_api: backend_apis[1])
    FactoryBot.create(:backend_api_config, service: services[2], backend_api: backend_apis[1])
    FactoryBot.create(:backend_api_config, service: services[3], backend_api: backend_apis[2])
    FactoryBot.create(:backend_api_config, service: services[3], backend_api: backend_apis[3])

    assert_equal [backend_apis[0].id], BackendApi.of_product(services[0]).pluck(:id)
    assert_equal [backend_apis[1].id], BackendApi.of_product(services[1]).pluck(:id)
    assert_equal [backend_apis[1].id], BackendApi.of_product(services[2]).pluck(:id)
    assert_same_elements backend_apis[2..3].map(&:id), BackendApi.of_product(services[3]).pluck(:id)
    assert_empty BackendApi.of_product(services[4]).pluck(:id)
  end

  test 'creates default metrics' do
    backend_api = FactoryBot.create(:backend_api)
    hits = backend_api.metrics.hits
    assert hits.default? :hits
  end

  test '#accessible does not return deleted backend apis' do
    backend_api_published = FactoryBot.create(:backend_api)
    backend_api_deleted = FactoryBot.create(:backend_api, state: :deleted)

    accessible_backend_apis = BackendApi.accessible.pluck(:id)
    assert_includes accessible_backend_apis, backend_api_published.id
    assert_not_includes accessible_backend_apis, backend_api_deleted.id
  end
end
