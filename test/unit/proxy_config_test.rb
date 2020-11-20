require 'test_helper'

class ProxyConfigTest < ActiveSupport::TestCase
  test '.by_version' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api)

    proxy_configs = FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first)

    assert_equal [proxy_configs.first.id],   ProxyConfig.by_version(1).pluck(:id)
    assert_equal [proxy_configs.second.id],  ProxyConfig.by_version(2).pluck(:id)
    assert_same_elements proxy_configs.map(&:id), ProxyConfig.by_version(nil).pluck(:id)
  end

  test '.latest_versions' do
    services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api)
    max_versions_proxy_configs_by_env = {}
    ProxyConfig::ENVIRONMENTS.each do |env|
      pcs = services.map do |service|
        FactoryBot.create(:proxy_config, proxy: service.proxy, environment: env)
      end.flatten
      max_versions_proxy_configs_by_env[env] = pcs.max_by(2) { |pc| pc.version }.map(&:id)
    end

    ProxyConfig::ENVIRONMENTS.each do |env|
      found_proxy_configs = ProxyConfig.latest_versions(environment: env).pluck(:id)
      assert_same_elements max_versions_proxy_configs_by_env[env], found_proxy_configs
    end

    assert_empty ProxyConfig.latest_versions(environment: 'production', proxy_ids: []).pluck(:id)
    assert_same_elements max_versions_proxy_configs_by_env['production'], ProxyConfig.latest_versions(environment: 'production', proxy_ids: nil).pluck(:id)
    assert_equal ProxyConfig.where(id: max_versions_proxy_configs_by_env['production']).where(proxy_id: services[0].proxy.id).pluck(:id),
                 ProxyConfig.latest_versions(environment: 'production', proxy_ids: [services[0].proxy.id]).pluck(:id)
  end

  test '.by_proxy_ids' do
    services = FactoryBot.create_list(:simple_service, 3, :with_default_backend_api)
    services.each { |s| FactoryBot.create_list(:proxy_config, 2, proxy: s.proxy) }

    search_proxy_ids = services[0..1].map { |s| s.proxy.id }
    assert_same_elements ProxyConfig.where(proxy_id: search_proxy_ids).pluck(:id), ProxyConfig.by_proxy_ids(search_proxy_ids).pluck(:id)
    assert_empty ProxyConfig.by_proxy_ids([]).pluck(:id)
    assert_same_elements ProxyConfig.all.pluck(:id), ProxyConfig.by_proxy_ids(nil).pluck(:id)
  end

  def test_clone_to
    ProxyConfig::ENVIRONMENTS.each do |environment|
      source_env    = (ProxyConfig::ENVIRONMENTS - [environment]).sample
      source_config = FactoryBot.create(:proxy_config, environment: source_env)

      assert_difference(ProxyConfig.where(environment: environment).method(:count)) do
        cloned_config = source_config.clone_to(environment: environment)
        assert_equal cloned_config.version, source_config.version
        assert_equal cloned_config.environment, environment

        refute source_config.clone_to(environment: environment).persisted?
      end
    end
  end

  def test_differs_from
    config_1 = FactoryBot.build_stubbed(:proxy_config, content: json_content(hosts: []))
    assert config_1.differs_from?(nil)

    config_2 = FactoryBot.build_stubbed(:proxy_config, content: json_content(hosts: []))
    refute config_1.differs_from?(config_2)

    config_3 = FactoryBot.build_stubbed(:proxy_config, content: json_content(hosts: ['foo']))
    assert config_1.differs_from?(config_3)
  end

  def test_denormalize_hosts
    config_1 = FactoryBot.create(:proxy_config, content: json_content(hosts: []))
    assert_nil config_1.read_attribute(:hosts)

    config_2 = FactoryBot.create(:proxy_config, content: json_content(hosts: ['example.com']), proxy: config_1.proxy)
    assert_equal '|example.com|', config_2.read_attribute(:hosts)

    config_3 = FactoryBot.create(:proxy_config, content: json_content(hosts: %w[example.com example.net]), proxy: config_1.proxy)
    assert_equal '|example.com|example.net|', config_3.read_attribute(:hosts)
  end

  def test_by_host
    FactoryBot.create(:proxy_config, content: json_content(hosts: ['example.com']))
    assert ProxyConfig.by_host('example.com').present?
    refute ProxyConfig.by_host('example.org').present?

    FactoryBot.create(:proxy_config, content: json_content(hosts: %w[example.com example.org]))
    assert ProxyConfig.by_host('example.com').present?
    assert ProxyConfig.by_host('example.org').present?
  end

  def test_hosts
    config = FactoryBot.build(:proxy_config)
    config.hosts = '|foo|bar|'
    assert_equal ['foo', 'bar'], config.hosts

    config.hosts = nil
    assert_equal [], config.hosts
  end

  def test_filename
    proxy = FactoryBot.create(:proxy)
    proxy_config = FactoryBot.create(:proxy_config, version: 1, proxy: proxy)
    proxy.service.name = 'bla ñé bla'
    assert_equal 'apicast-config-bla-ne-bla-sandbox-1.json', proxy_config.filename
  end

  def test_by_environment
    sandbox = FactoryBot.create(:proxy_config, environment: 'sandbox')
    production  = FactoryBot.create(:proxy_config, environment: 'production')

    assert_equal [ sandbox ], ProxyConfig.by_environment('sandbox')
    assert_equal [ sandbox ], ProxyConfig.by_environment('staging')
    assert_equal [ production ], ProxyConfig.by_environment('production')

    assert_raises ProxyConfig::InvalidEnvironmentError do
      ProxyConfig.by_environment('foobar')
    end
  end

  def test_create_without_service_token
    service = FactoryBot.create(:simple_service)
    proxy = FactoryBot.create(:proxy, service: service)
    proxy_config = FactoryBot.build(:proxy_config, environment: 'sandbox', proxy: proxy)
    service.service_tokens.delete_all
    refute proxy_config.valid?
    assert_contains proxy_config.errors[:service_token], proxy_config.errors.generate_message(:service_token, :missing)
  end

  test 'missing api backend' do
    service = FactoryBot.create(:simple_service)
    proxy = FactoryBot.create(:proxy, service: service)
    proxy_config = FactoryBot.build(:proxy_config, environment: 'sandbox', proxy: proxy)

    proxy.backend_api_configs.delete_all
    proxy.reload
    refute proxy_config.valid?
    assert_equal :missing, proxy_config.errors.details[:api_backend].first[:error]

    service.backend_api_configs.create!(backend_api: FactoryBot.create(:backend_api, account: service.account), path: '/')
    proxy.reload
    assert proxy_config.valid?
  end

  test 'missing api backend when service_mesh' do
    service = FactoryBot.create(:simple_service)
    proxy = service.proxy
    proxy.stubs(:service_mesh_integration?).returns(true)
    proxy_config = FactoryBot.build(:proxy_config, proxy: proxy)

    proxy.backend_api_configs.delete_all
    proxy.reload
    assert proxy_config.valid?
  end

  def test_maximum_length
    proxy_config = FactoryBot.build(:proxy_config)
    content = proxy_config.content
    json = JSON.parse(content).deep_symbolize_keys
    json.merge!(foo: 'a' * 2.megabytes)
    content = json.to_json
    proxy_config.content = content

    refute proxy_config.valid?
    assert_contains proxy_config.errors[:content], proxy_config.errors.generate_message(:content, :too_long, count: ProxyConfig::MAX_CONTENT_LENGTH)
  end

  private

  def json_content(hosts: [])
    { proxy: { hosts: hosts }}.to_json
  end
end
