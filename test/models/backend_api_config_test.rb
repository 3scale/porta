require 'test_helper'

class BackendApiConfigTest < ActiveSupport::TestCase
  def setup
    @config = BackendApiConfig.new(path: '/')
  end

  def test_includes_initial_slash_from_private_endpoint
    @config.path = 'hello'
    assert_equal '/hello', @config.path

    @config.path = '/hello'
    assert_equal '/hello', @config.path

    @config.path = 'hello/my/name/is'
    assert_equal '/hello/my/name/is', @config.path

    @config.path = '//hello/my/name/is/john//'
    assert_equal '/hello/my/name/is/john', @config.path
  end

  def test_path_field_must_be_a_path
    @config.path = 'https://example.com/hello'
    refute @config.valid?
    assert_match /must be a path/, @config.errors[:path].join('')
  end

  test 'scope with_subpath' do
    bac_slash = FactoryBot.create(:backend_api_config, path: '/').id
    bac_path_foo = FactoryBot.create(:backend_api_config, path: '/foo').id
    bac_path_null = FactoryBot.create(:backend_api_config, path: '/null').id
    bac_path_longer = FactoryBot.create(:backend_api_config, path: '/hello/my/name/is/john').id

    backend_api_config_ids_with_subpath = BackendApiConfig.with_subpath.pluck(:id)
    assert_not_includes backend_api_config_ids_with_subpath, bac_slash
    assert_includes backend_api_config_ids_with_subpath, bac_path_foo
    assert_includes backend_api_config_ids_with_subpath, bac_path_null
    assert_includes backend_api_config_ids_with_subpath, bac_path_longer
  end

  test 'validates presence of service' do
    @config.backend_api = FactoryBot.build_stubbed(:backend_api)

    refute @config.valid?
    assert @config.errors[:service_id].include? "can't be blank"

    @config.service = FactoryBot.build_stubbed(:simple_service)
    assert @config.valid?
  end

  test 'validates presence of backend_api' do
    @config.service = FactoryBot.build_stubbed(:simple_service)

    refute @config.valid?
    assert @config.errors[:backend_api_id].include? "can't be blank"

    @config.backend_api = FactoryBot.build_stubbed(:backend_api)
    assert @config.valid?
  end

  test 'validates uniqueness of path' do
    service = FactoryBot.create(:simple_service)
    service.backend_api_configs.create backend_api: FactoryBot.create(:backend_api, account: service.account), path: 'foo'

    @config.service = service
    @config.backend_api = FactoryBot.create(:backend_api, account: service.account)
    @config.path = 'foo'
    refute @config.valid?
    assert @config.errors[:path].include? 'This path is already taken. Specify a different path.'

    @config.path = 'bar'
    assert @config.valid?
  end

  test 'validates uniqueness of backend_api within service' do
    service = FactoryBot.create(:simple_service)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)

    @config.service = service
    @config.backend_api = backend_api
    @config.path = 'another_path'
    refute @config.valid?
    assert_includes @config.errors[:backend_api_id], 'has already been taken'

    @config.backend_api = FactoryBot.create(:backend_api, account: service.account)
    assert @config.valid?
    assert_empty @config.errors[:backend_api_id]
  end

  test '.by_service returns the configs related to that service' do
    account = FactoryBot.create(:simple_account)
    services = FactoryBot.create_list(:service, 3, account: account)
    backend_apis = FactoryBot.create_list(:backend_api, 3, account: account)

    configs = 2.times.map do |index|
      FactoryBot.create(:backend_api_config, backend_api: backend_apis[index], service: services[index])
    end
    configs << FactoryBot.create(:backend_api_config, service: services[0])

    assert_same_elements configs.values_at(0, -1).map(&:id), BackendApiConfig.by_service(services[0].id).pluck(:id)
    assert_equal [configs[1].id], BackendApiConfig.by_service(services[1].id).pluck(:id)
    assert_empty BackendApiConfig.by_service(services[2].id).pluck(:id)
  end

  test '.by_backend_api returns the configs related to that backend_api' do
    account = FactoryBot.create(:simple_account)
    services = FactoryBot.create_list(:service, 3, account: account)
    backend_apis = FactoryBot.create_list(:backend_api, 3, account: account)

    configs = 2.times.map do |index|
      FactoryBot.create(:backend_api_config, backend_api: backend_apis[index], service: services[index])
    end
    configs << FactoryBot.create(:backend_api_config, backend_api: backend_apis[0])

    assert_same_elements configs.values_at(0, -1).map(&:id), BackendApiConfig.by_backend_api(backend_apis[0].id).pluck(:id)
    assert_equal [configs[1].id], BackendApiConfig.by_backend_api(backend_apis[1].id).pluck(:id)
    assert_empty BackendApiConfig.by_backend_api(backend_apis[2].id).pluck(:id)
  end

  test 'accessible' do
    backend_api_configs = FactoryBot.create_list(:backend_api_config, 2)
    services = backend_api_configs.map(&:service)
    services[0].mark_as_deleted!

    accessible_backend_api_config_ids = BackendApiConfig.accessible.pluck(:id)
    assert_includes     accessible_backend_api_config_ids, backend_api_configs[1].id
    assert_not_includes accessible_backend_api_config_ids, backend_api_configs[0].id
  end

  class ProxyConfigAffectingChangesTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      provider = FactoryBot.create(:provider_account)
      @service = provider.first_service
      @backend_api = FactoryBot.create(:backend_api, account: provider)
    end

    attr_reader :service, :backend_api

    test 'tracks changes on create' do
      with_proxy_config_affecting_changes_tracker do |tracker|
        backend_api_config = FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service, path: '/whatever')
        assert tracker.tracking?(ProxyConfigAffectingChanges::TrackedObject.new(backend_api_config))
      end
    end

    test 'tracks changes on update' do
      backend_api_config = FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service, path: '/whatever')
      tracked_object = ProxyConfigAffectingChanges::TrackedObject.new(backend_api_config)

      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        backend_api_config.update(path: '/new-path')
        assert tracker.tracking?(tracked_object)
      end
    end

    test 'tracks changes on destroy' do
      backend_api_config = FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service, path: '/whatever')
      tracked_object = ProxyConfigAffectingChanges::TrackedObject.new(backend_api_config)

      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        backend_api_config.destroy
        assert tracker.tracking?(tracked_object)
      end
    end
  end
end
