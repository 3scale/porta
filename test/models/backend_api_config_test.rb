require 'test_helper'

class BackendApiConfigTest < ActiveSupport::TestCase
  def setup
    @config = BackendApiConfig.new
  end

  def test_strip_slashes_from_private_endpoint
    @config.path = '/hello'
    assert_equal 'hello', @config.path

    @config.path = 'hello/my/name/is'
    assert_equal 'hello/my/name/is', @config.path

    @config.path = 'hello/my/name/is/'
    assert_equal 'hello/my/name/is', @config.path

    @config.path = '//hello/my/name/is/john//'
    assert_equal 'hello/my/name/is/john', @config.path
  end

  def test_path_field_must_be_a_path
    @config.path = 'https://example.com/hello'
    refute @config.valid?
    assert_match /must be a path/, @config.errors[:path].join('')
  end

  test 'scope with_subpath' do
    bac_slash = FactoryBot.create(:backend_api_config, path: '/').id
    bac_empty = FactoryBot.create(:backend_api_config, path: '').id
    bac_path_foo = FactoryBot.create(:backend_api_config, path: '/foo').id
    bac_path_null = FactoryBot.create(:backend_api_config, path: '/null').id
    bac_path_longer = FactoryBot.create(:backend_api_config, path: '/hello/my/name/is/john').id

    backend_api_config_ids_with_subpath = BackendApiConfig.with_subpath.pluck(:id)
    assert_not_includes backend_api_config_ids_with_subpath, bac_slash
    assert_not_includes backend_api_config_ids_with_subpath, bac_empty
    assert_includes backend_api_config_ids_with_subpath, bac_path_foo
    assert_includes backend_api_config_ids_with_subpath, bac_path_null
    assert_includes backend_api_config_ids_with_subpath, bac_path_longer
  end

  test 'validates presence of service' do
    @config.backend_api = FactoryBot.build_stubbed(:backend_api)

    refute @config.valid?
    assert @config.errors[:service_id].include? "can't be blank"

    @config.service = FactoryBot.build_stubbed(:simple_service, account: @config.backend_api.account)
    assert @config.valid?
  end

  test 'validates presence of backend_api' do
    @config.service = FactoryBot.build_stubbed(:simple_service)

    refute @config.valid?
    assert @config.errors[:backend_api_id].include? "can't be blank"

    @config.backend_api = FactoryBot.build_stubbed(:backend_api, account: @config.service.account)
    assert @config.valid?
  end

  test 'validates uniqueness of path' do
    service = FactoryBot.create(:simple_service)
    service.backend_api_configs.create backend_api: FactoryBot.create(:backend_api, account: service.account), path: 'foo'

    @config.service = service
    @config.backend_api = FactoryBot.create(:backend_api, account: service.account)
    @config.path = 'foo'
    refute @config.valid?
    assert @config.errors[:path].include? 'has already been taken'

    @config.path = 'bar'
    assert @config.valid?
  end

  test 'validates service and backend api belong to the same tenant' do
    service = FactoryBot.create(:simple_service)
    backend_api_same_tenant = FactoryBot.create(:backend_api, account: service.account)
    backend_api_different_tenant = FactoryBot.create(:backend_api, account: FactoryBot.create(:simple_provider))

    backend_api_config = FactoryBot.build(:backend_api_config, service: service, backend_api: backend_api_same_tenant)
    assert backend_api_config.valid?
    assert_empty backend_api_config.errors.full_messages

    backend_api_config = FactoryBot.build(:backend_api_config, service: service, backend_api: backend_api_different_tenant)
    refute backend_api_config.valid?
    assert_includes backend_api_config.errors[:service], 'must belong to the same tenant as the backend api'
  end
end
