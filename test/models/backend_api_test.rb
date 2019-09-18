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
    @backend_api.private_endpoint = 'https://example.org:3/path'
    @backend_api.valid?
    assert_equal [@backend_api.errors.generate_message(:private_endpoint, :invalid)], @backend_api.errors.messages[:private_endpoint]

    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(true)
    @backend_api.private_endpoint = 'https://example.org:3/path'
    assert @backend_api.valid?
  end

  test '.orphans should return backend apis that do not belongs to any service' do
    FactoryBot.create(:service)
    service_to_delete = FactoryBot.create(:simple_service, :with_default_backend_api)
    orphan_backend_api = service_to_delete.backend_api_configs.first.backend_api

    assert_equal [], BackendApi.orphans

    service_to_delete.destroy_default

    assert_equal [orphan_backend_api], BackendApi.orphans
  end

  test 'creates default metrics' do
    backend_api = FactoryBot.create(:backend_api)
    hits = backend_api.metrics.hits
    assert hits.default? :hits
  end
end
