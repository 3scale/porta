require 'test_helper'

class ProxyConfigTest < ActiveSupport::TestCase

  def test_clone_to
    ProxyConfig::ENVIRONMENTS.each do |environment|
      source_env    = (ProxyConfig::ENVIRONMENTS - [environment]).sample
      source_config = FactoryGirl.create(:proxy_config, environment: source_env)

      assert_difference(ProxyConfig.where(environment: environment).method(:count)) do
        cloned_config = source_config.clone_to(environment: environment)
        assert_equal cloned_config.version, source_config.version
        assert_equal cloned_config.environment, environment

        refute source_config.clone_to(environment: environment).persisted?
      end
    end
  end

  def test_differs_from
    config_1 = FactoryGirl.build_stubbed(:proxy_config, content: json_content(hosts: []))
    assert config_1.differs_from?(nil)

    config_2 = FactoryGirl.build_stubbed(:proxy_config, content: json_content(hosts: []))
    refute config_1.differs_from?(config_2)

    config_3 = FactoryGirl.build_stubbed(:proxy_config, content: json_content(hosts: ['foo']))
    assert config_1.differs_from?(config_3)
  end

  def test_denormalize_hosts
    config_1 = FactoryGirl.create(:proxy_config, content: json_content(hosts: []))
    assert_nil config_1.read_attribute(:hosts)

    config_2 = FactoryGirl.create(:proxy_config, content: json_content(hosts: ['example.com']), proxy: config_1.proxy)
    assert_equal '|example.com|', config_2.read_attribute(:hosts)

    config_3 = FactoryGirl.create(:proxy_config, content: json_content(hosts: %w[example.com example.net]), proxy: config_1.proxy)
    assert_equal '|example.com|example.net|', config_3.read_attribute(:hosts)
  end

  def test_by_host
    FactoryGirl.create(:proxy_config, content: json_content(hosts: ['example.com']))
    assert ProxyConfig.by_host('example.com').present?
    refute ProxyConfig.by_host('example.org').present?

    FactoryGirl.create(:proxy_config, content: json_content(hosts: %w[example.com example.org]))
    assert ProxyConfig.by_host('example.com').present?
    assert ProxyConfig.by_host('example.org').present?
  end

  def test_hosts
    config = FactoryGirl.build(:proxy_config)
    config.hosts = '|foo|bar|'
    assert_equal ['foo', 'bar'], config.hosts

    config.hosts = nil
    assert_equal [], config.hosts
  end

  def test_current_versions
    proxy = FactoryGirl.create(:proxy)
    FactoryGirl.create(:proxy_config, version: 1, proxy: proxy)
    assert_equal [1], ProxyConfig.current_versions.pluck(:version)

    FactoryGirl.create(:proxy_config, version: 2, proxy: proxy)
    assert_equal [2], ProxyConfig.current_versions.pluck(:version)

    assert ProxyConfig.current_versions.to_a
  end

  def test_filename
    proxy = FactoryGirl.create(:proxy)
    proxy_config = FactoryGirl.create(:proxy_config, version: 1, proxy: proxy)
    proxy.service.name = 'bla ñé bla'
    assert_equal 'apicast-config-bla-ne-bla-sandbox-1.json', proxy_config.filename
  end

  def test_by_environment
    sandbox = FactoryGirl.create(:proxy_config, environment: 'sandbox')
    production  = FactoryGirl.create(:proxy_config, environment: 'production')

    assert_equal [ sandbox ], ProxyConfig.by_environment('sandbox')
    assert_equal [ sandbox ], ProxyConfig.by_environment('staging')
    assert_equal [ production ], ProxyConfig.by_environment('production')

    assert_raises ProxyConfig::InvalidEnvironmentError do
      ProxyConfig.by_environment('foobar')
    end
  end

  def test_create_without_service_token
    service = FactoryGirl.create(:simple_service)
    proxy = FactoryGirl.create(:proxy, service: service)
    proxy_config = FactoryGirl.build(:proxy_config, environment: 'sandbox', proxy: proxy)
    service.service_tokens.delete_all
    refute proxy_config.valid?
    assert_contains proxy_config.errors[:service_token], proxy_config.errors.generate_message(:service_token, :missing)
  end

  def test_maximum_length
    proxy_config = FactoryGirl.build(:proxy_config)
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
