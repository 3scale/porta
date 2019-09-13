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
end
