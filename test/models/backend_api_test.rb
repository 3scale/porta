require 'test_helper'

class BackendApiTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
    @backend_api = BackendApi.new(account: @account, name: 'My Backend')
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

  test 'allows to use http or wss protocol in private_endpoint' do
    @backend_api.private_endpoint = 'http://example.org:3/path'
    assert @backend_api.valid?
    @backend_api.private_endpoint = 'https://example.org:3/path'
    assert @backend_api.valid?

    @backend_api.private_endpoint = 'ws://example.org:3/path'
    assert @backend_api.valid?
    @backend_api.private_endpoint = 'wss://example.org:3/path'
    assert @backend_api.valid?
  end

  test '.not_used_by returns the backend apis that are not related to that service' do
    account = FactoryBot.create(:simple_provider)
    backend_api_not_used_by_any_service = FactoryBot.create(:backend_api, account: account)
    backend_api_using_one_service = FactoryBot.create(:backend_api, account: account)
    backend_api_using_two_services = FactoryBot.create(:backend_api, account: account)

    services = FactoryBot.create_list(:service, 4, account: account)

    configs = []
    configs << services[0].backend_api_configs.create!(backend_api: backend_api_using_one_service, path: 'foo')
    configs << services[1].backend_api_configs.create!(backend_api: backend_api_using_two_services, path: 'foo')
    configs << services[2].backend_api_configs.create!(backend_api: backend_api_using_two_services, path: 'bar')

    assert_same_elements [backend_api_not_used_by_any_service, backend_api_using_two_services].map(&:id), BackendApi.not_used_by(services[0].id).pluck(:id)
    assert_same_elements [backend_api_not_used_by_any_service, backend_api_using_one_service].map(&:id), BackendApi.not_used_by(services[1].id).pluck(:id)
    assert_same_elements [backend_api_not_used_by_any_service, backend_api_using_one_service].map(&:id), BackendApi.not_used_by(services[2].id).pluck(:id)
    assert_same_elements [backend_api_not_used_by_any_service, backend_api_using_one_service, backend_api_using_two_services].map(&:id), BackendApi.not_used_by(services[3].id).pluck(:id)
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

  test 'can be destroyed or marked as deleted only if it is destroyed by association or does not have backend api configs' do
    backend_api = FactoryBot.create(:backend_api)
    assert backend_api.mark_as_deleted
    backend_api.destroy
    refute BackendApi.exists? backend_api.id

    backend_api = FactoryBot.create(:backend_api_config).backend_api
    refute backend_api.mark_as_deleted
    backend_api.destroy
    assert BackendApi.exists? backend_api.id

    assert backend_api.account.destroy
    refute BackendApi.exists? backend_api.id
  end

  class ProxyConfigAffectingChangesTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      provider = FactoryBot.create(:provider_account)
      @service = provider.first_service
      @backend_api = FactoryBot.create(:backend_api, account: provider)
      FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service, path: '/whatever')
      @tracked_object = ProxyConfigAffectingChanges::TrackedObject.new(backend_api)
    end

    attr_reader :service, :backend_api, :tracked_object

    test 'tracks changes on update of endpoint' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        backend_api.update(name: 'new-name')
        refute tracker.tracking?(tracked_object)
        backend_api.update(api_backend: 'https://new-endpoint.test')
        assert tracker.tracking?(tracked_object)
      end
    end

    test 'tracks changes on destroy' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        backend_api.destroy
        assert tracker.tracking?(tracked_object)
      end
    end
  end

  class DisableTransactionalFixturesTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test '.orphans should return backend apis that do not belongs to any service' do
      account = FactoryBot.create(:account)
      FactoryBot.create(:service, account: account)
      service_to_delete = FactoryBot.create(:simple_service, :with_default_backend_api, system_name: 'orphan_system', account: account)
      orphan_backend_api = service_to_delete.backend_api_configs.first.backend_api

      assert_equal [], BackendApi.orphans.pluck(:id)

      service_to_delete.destroy!
      assert_equal 0, orphan_backend_api.services.count
      assert_equal 0, orphan_backend_api.backend_api_configs.count

      assert_equal [orphan_backend_api.id], BackendApi.orphans.pluck(:id)
    end
  end
end
