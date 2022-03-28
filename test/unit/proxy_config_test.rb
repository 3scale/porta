# frozen_string_literal: true

require 'test_helper'

class ProxyConfigTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength

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
    c1 = FactoryBot.create(:proxy_config, content: json_content(hosts: ['example.com']))
    assert_same_elements [c1], ProxyConfig.by_host('example.com')
    assert_empty ProxyConfig.by_host('example')
    assert_empty ProxyConfig.by_host('.com')

    c2 = FactoryBot.create(:proxy_config, content: json_content(hosts: ['example.com', 'example.org']))
    assert_same_elements [c1, c2], ProxyConfig.by_host('example.com')
    assert_same_elements [c2], ProxyConfig.by_host('example.org')

    assert_empty ProxyConfig.by_host('')
    assert_same_elements [c1, c2], ProxyConfig.by_host(nil)
  end

  def test_hosts
    config = FactoryBot.build(:proxy_config)
    config.hosts = '|foo|bar|'
    assert_equal ['foo', 'bar'], config.hosts

    config.hosts = nil
    assert_equal [], config.hosts
  end

  test '#current_versions: a service deploys to a new host' do
    proxy = FactoryBot.create(:proxy)

    old_config = FactoryBot.create(:proxy_config, proxy: proxy, content: json_content(hosts: ['v1.example.com']), environment: 'production')
    new_config = FactoryBot.create(:proxy_config, proxy: proxy, content: json_content(hosts: ['v2.example.com']), environment: 'production')

    assert_same_elements [new_config], ProxyConfig.current_versions
  end

  test '#current_versions: a service deploys to a different env' do
    proxy = FactoryBot.create(:proxy)

    sand_config = FactoryBot.create(:proxy_config, proxy: proxy, content: json_content(hosts: ['staging.example.com']), environment: 'sandbox')
    prod_config = FactoryBot.create(:proxy_config, proxy: proxy, content: json_content(hosts: ['prod.example.com']), environment: 'production')

    assert_same_elements [sand_config, prod_config], ProxyConfig.current_versions
  end

  test '#current_versions returns 1 config per proxy and per environment' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    current_versions = [
      create_proxy_configs(3, proxy1, 'sandbox').last,
      create_proxy_configs(4, proxy1, 'production').last,
      create_proxy_configs(2, proxy2, 'sandbox').last,
      create_proxy_configs(6, proxy2, 'production').last,
    ]

    assert_same_elements current_versions, ProxyConfig.current_versions
  end

  test '#current_versions returns 1 config per proxy for a single environment' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    sandbox_current_versions = [
      create_proxy_configs(3, proxy1, 'sandbox').last,
      create_proxy_configs(2, proxy2, 'sandbox').last,
    ]

    production_current_versions = [
      create_proxy_configs(4, proxy1, 'production').last,
      create_proxy_configs(6, proxy2, 'production').last,
    ]

    assert_same_elements sandbox_current_versions, ProxyConfig.by_environment('sandbox').current_versions
    assert_same_elements production_current_versions, ProxyConfig.by_environment('production').current_versions
  end

  test '#current_versions returns 1 config per proxy and per host, when it is latest' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    c1 = FactoryBot.create(:proxy_config, proxy: proxy1, content: json_content(hosts: ['old.example.com']))
    c2 = FactoryBot.create(:proxy_config, proxy: proxy1, content: json_content(hosts: ['new.example.com']))
    c3 = FactoryBot.create(:proxy_config, proxy: proxy1, content: json_content(hosts: ['new.example.com']))

    c4 = FactoryBot.create(:proxy_config, proxy: proxy2, content: json_content(hosts: ['old.example.com']))
    c5 = FactoryBot.create(:proxy_config, proxy: proxy2, content: json_content(hosts: ['new.example.com']))
    c6 = FactoryBot.create(:proxy_config, proxy: proxy2, content: json_content(hosts: ['new.example.com']))

    assert_empty ProxyConfig.by_host('old.example.com').current_versions
    assert_same_elements [c3, c6], ProxyConfig.by_host('new.example.com').current_versions
  end

  test '#current_versions returns 1 config per proxy for a single environment and host' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)
    proxy3 = FactoryBot.create(:proxy)

    c1 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy1, content: json_content(hosts: ['example.com']), environment: 'sandbox').last
    c2 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy1, content: json_content(hosts: ['example.com']), environment: 'production').last

    c3 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy2, content: json_content(hosts: ['example.com']), environment: 'sandbox').last
    c4 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy2, content: json_content(hosts: ['example.com']), environment: 'production').last

    c5 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy3, content: json_content(hosts: ['other.example.com']), environment: 'sandbox').last
    c6 = FactoryBot.create_list(:proxy_config, 2, proxy: proxy3, content: json_content(hosts: ['other.example.com']), environment: 'production').last

    assert_equal [],  ProxyConfig.sandbox.by_host('unknown').current_versions # assert_empty raises an error in mysql
    assert_same_elements [c1, c3], ProxyConfig.sandbox.by_host('example.com').current_versions
    assert_same_elements [c2, c4], ProxyConfig.production.by_host('example.com').current_versions
  end

  test '#current_versions do not ignore configs for unavailable services' do
    service = FactoryBot.create(:service)
    proxy1 = FactoryBot.create(:proxy, service: service)
    proxy2 = FactoryBot.create(:proxy)

    c1 = FactoryBot.create(:proxy_config, proxy: proxy1)
    c2 = FactoryBot.create(:proxy_config, proxy: proxy2)

    assert_same_elements [c1, c2], ProxyConfig.current_versions

    service.update(state: Service::DELETE_STATE)
    assert_same_elements [c1, c2], ProxyConfig.current_versions
  end

  test '#current_versions for available services only' do
    account = FactoryBot.create(:account)

    service1 = FactoryBot.create(:service, account: account)
    service2 = FactoryBot.create(:service, account: account)

    proxy1 = FactoryBot.create(:proxy, service: service1)
    proxy2 = FactoryBot.create(:proxy, service: service2)

    c1 = FactoryBot.create_list(:proxy_config, 3, proxy: proxy1).last
    c2 = FactoryBot.create_list(:proxy_config, 3, proxy: proxy2).last
    c3 = FactoryBot.create(:proxy_config)

    assert_same_elements [c1, c2, c3], ProxyConfig.current_versions

    # TODO: THREESCALE-8208: remove next line
    assert_same_elements [c1, c2], account.accessible_proxy_configs.current_versions

    service1.update(state: 'deleted')
    # TODO: THREESCALE-8208: remove next line
    assert_same_elements [c2], account.accessible_proxy_configs.current_versions
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

  test '#by_version returns all configs with given version' do
    configs_v2 = []
    proxies = FactoryBot.create_list(:proxy, 3)
    proxies.each do |p|
      FactoryBot.create(:proxy_config, version: 1, proxy: p)
      configs_v2 << FactoryBot.create(:proxy_config, version: 2, proxy: p)
      FactoryBot.create(:proxy_config, version: 3, proxy: p)
    end

    assert_same_elements configs_v2, ProxyConfig.by_version(2)
    assert_empty ProxyConfig.by_version(5)
  end

  test '#by_version returns the latest version of each proxy' do
    latest_versions = []
    proxies = FactoryBot.create_list(:proxy, 3)
    proxies.each { |p| latest_versions << FactoryBot.create_list(:proxy_config, 3, proxy: p).last }

    assert_same_elements latest_versions, ProxyConfig.by_version('latest')
  end

  test '#by_version returns all configs with given version for a particular environment' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)
    proxy3 = FactoryBot.create(:proxy)

    sandbox_v2 = [
      FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'sandbox'),
      FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'sandbox'),
    ]

    production_v2 = [
      FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'production'),
      FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'production'),
    ]

    FactoryBot.create(:proxy_config, version: 3, proxy: proxy3, environment: 'production')
    FactoryBot.create(:proxy_config, version: 3, proxy: proxy3, environment: 'sandbox')

    assert_same_elements sandbox_v2, ProxyConfig.by_version(2).by_environment('sandbox')
    assert_same_elements production_v2, ProxyConfig.by_version(2).by_environment('production')
  end

  test '#by_version returns the latest version of each proxy for a particular environment' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    sandbox_latest = [
      FactoryBot.create_list(:proxy_config, 2, proxy: proxy1, environment: 'sandbox').last,
      FactoryBot.create_list(:proxy_config, 4, proxy: proxy2, environment: 'sandbox').last,
    ]

    production_latest = [
      FactoryBot.create_list(:proxy_config, 4, proxy: proxy1, environment: 'production').last,
      FactoryBot.create_list(:proxy_config, 2, proxy: proxy2, environment: 'production').last,
    ]

    assert_same_elements sandbox_latest, ProxyConfig.by_version('latest').by_environment('sandbox')
    assert_same_elements production_latest, ProxyConfig.by_version('latest').by_environment('production')
  end

  test '#by_version returns all configs with given version for a particular host' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    example_v2 = FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'production', content: json_content(hosts: ['foo.example.com']))
    FactoryBot.create(:proxy_config, version: 3, proxy: proxy1, environment: 'production', content: json_content(hosts: ['foo.example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'production', content: json_content(hosts: ['new.example.com']))

    assert_same_elements [example_v2], ProxyConfig.by_version(2).by_host('foo.example.com')
    assert_empty ProxyConfig.by_version(2).by_host('example.com')
  end

  test '#by_version returns the latest version of each proxy for a particular host' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))
    latest_p1 = FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))

    FactoryBot.create(:proxy_config, version: 3, proxy: proxy2, environment: 'production', content: json_content(hosts: ['example.com']))
    latest_p2 = FactoryBot.create(:proxy_config, version: 4, proxy: proxy2, environment: 'production', content: json_content(hosts: ['new.example.com']))

    assert_same_elements [latest_p1], ProxyConfig.by_version('latest').by_host('example.com')
    assert_same_elements [latest_p2], ProxyConfig.by_version('latest').by_host('new.example.com')
  end

  test '#by_version returns all configs with given version for a particular environtment and host' do
    expected_configs = []
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)
    proxy3 = FactoryBot.create(:proxy)

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))
    expected_configs << FactoryBot.create(:proxy_config, version: 1, proxy: proxy1, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'sandbox', content: json_content(hosts: ['example.com']))

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy2, environment: 'production', content: json_content(hosts: ['example.com']))
    expected_configs << FactoryBot.create(:proxy_config, version: 1, proxy: proxy2, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'production', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'sandbox', content: json_content(hosts: ['example.com']))

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy3, environment: 'production', content: json_content(hosts: ['v3.example.com']))
    FactoryBot.create(:proxy_config, version: 1, proxy: proxy3, environment: 'sandbox', content: json_content(hosts: ['v3.example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy3, environment: 'production', content: json_content(hosts: ['v3.example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy3, environment: 'sandbox', content: json_content(hosts: ['v3.example.com']))

    assert_same_elements expected_configs, ProxyConfig.by_version(1).by_host('example.com').by_environment('sandbox')
  end

  test '#by_version returns the latest version of each proxy for a particular environtment and host' do
    proxy1 = FactoryBot.create(:proxy)
    proxy2 = FactoryBot.create(:proxy)
    proxy3 = FactoryBot.create(:proxy)

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 1, proxy: proxy1, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'production', content: json_content(hosts: ['example.com']))
    res1 = FactoryBot.create(:proxy_config, version: 2, proxy: proxy1, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    res3 = FactoryBot.create(:proxy_config, version: 3, proxy: proxy1, environment: 'production', content: json_content(hosts: ['new.example.com']))

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy2, environment: 'production', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 1, proxy: proxy2, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    res2 = FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'production', content: json_content(hosts: ['example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy2, environment: 'sandbox', content: json_content(hosts: ['example.com']))
    res4 = FactoryBot.create(:proxy_config, version: 3, proxy: proxy2, environment: 'sandbox', content: json_content(hosts: ['new.example.com']))

    FactoryBot.create(:proxy_config, version: 1, proxy: proxy3, environment: 'production', content: json_content(hosts: ['v3.example.com']))
    FactoryBot.create(:proxy_config, version: 1, proxy: proxy3, environment: 'sandbox', content: json_content(hosts: ['v3.example.com']))
    FactoryBot.create(:proxy_config, version: 2, proxy: proxy3, environment: 'production', content: json_content(hosts: ['v3.example.com']))
    res5 = FactoryBot.create(:proxy_config, version: 2, proxy: proxy3, environment: 'sandbox', content: json_content(hosts: ['v3.example.com']))

    assert_same_elements [res1], ProxyConfig.by_version('latest').by_host('example.com').by_environment('sandbox')
    assert_same_elements [res2], ProxyConfig.by_version('latest').by_host('example.com').by_environment('production')
    assert_same_elements [res3], ProxyConfig.by_version('latest').by_host('new.example.com').by_environment('production')
    assert_same_elements [res4], ProxyConfig.by_version('latest').by_host('new.example.com').by_environment('sandbox')
    assert_same_elements [res5], ProxyConfig.by_version('latest').by_host('v3.example.com').by_environment('sandbox')
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

  def create_proxy_configs(length, proxy, env)
    content = case env
      when 'production' then json_content(hosts: ['production.example.com'])
      when 'sandbox' then json_content(hosts: ['sandbox.example.com'])
    end

    FactoryBot.create_list(:proxy_config, length, proxy: proxy, content: content, environment: env)
  end
end
