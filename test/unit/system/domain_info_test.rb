# frozen_string_literal: true

require 'test_helper'

class System::DomainInfoTest < ActiveSupport::TestCase
  test '#as_json' do
    domain_info = System::DomainInfo.find('example.com')

    assert_equal({
                   'domain' => 'example.com',
                   'master' => false,
                   'provider' => false,
                   'developer' => false,
                   'apicast' => { 'staging' => false, 'production' => false } },
                 domain_info.as_json)
  end

  test '.find' do
    domain_info = System::DomainInfo.find(master_account.domain)

    assert domain_info.master
    assert domain_info.developer
    refute domain_info.provider
    refute domain_info.apicast_staging
    refute domain_info.apicast_production
  end

  class ApicastInfoTest < ActiveSupport::TestCase
    disable_transactional_fixtures! if System::Database.oracle?

    test 'staging false, production false. Search an old version' do
      service = FactoryBot.create(:simple_service, :with_default_backend_api)

      hosts = %w[3scale.net example.com]
      FactoryBot.create(:proxy_config, environment: 'production', proxy: service.proxy,
      content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", endpoint: "http://#{hosts[1]}:80" } }.to_json)

      hosts = %w[example.org 3scale.localhost]
      FactoryBot.create(:proxy_config, environment: 'production', proxy: service.proxy,
      content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", endpoint: "http://#{hosts[1]}:80" } }.to_json)

      apicast_info = System::DomainInfo.apicast_info('3scale.net')
      refute apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('example.com')
      refute apicast_info.staging
      refute apicast_info.production
    end

    test 'staging true, production false. Searc staging environments of different services' do
      hosts = %w[3scale.net example.com]
      FactoryBot.create(:proxy_config, environment: 'sandbox',
      content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", endpoint: "http://#{hosts[1]}:80" } }.to_json)

      hosts = %w[example.org 3scale.localhost]
      FactoryBot.create(:proxy_config, environment: 'sandbox',
      content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", endpoint: "http://#{hosts[1]}:80" } }.to_json)

      apicast_info = System::DomainInfo.apicast_info('3scale.net')
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('example.com')
      refute apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('example.org')
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('3scale.localhost')
      refute apicast_info.staging
      refute apicast_info.production
    end

    test 'staging false, production true & staging true, production false. Latest versions for the same service' do
      services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api)

      hosts_list = [
        %w[example.org 3scale.net],
        %w[3scale.localhost example.org],
        %w[3sca.net example.org],
        %w[3scale.net 3sca.net]
      ]

      services.each do |service|
        hosts_list.each do |hosts|
          ProxyConfig::ENVIRONMENTS.each do |env|
            FactoryBot.create(:proxy_config,
            proxy: service.proxy,
            environment: env,
            content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", endpoint: "http://#{hosts[1]}:80" } }.to_json)
          end
        end
      end

      apicast_info = System::DomainInfo.apicast_info('3scale.net')
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('3sca.net')
      refute apicast_info.staging
      assert apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('example.org')
      refute apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('3scale.localhost')
      refute apicast_info.staging
      refute apicast_info.production
    end

    test 'staging true, production true. Same service and version, different environment' do
      service = FactoryBot.create(:simple_service, :with_default_backend_api)

      hosts = %w[3scale.net]

      FactoryBot.create(:proxy_config, environment: 'production', proxy: service.proxy,
      content: { proxy: { hosts: hosts, endpoint: "http://#{hosts[0]}:80" } }.to_json)

      FactoryBot.create(:proxy_config, environment: 'sandbox', proxy: service.proxy,
      content: { proxy: { hosts: hosts, sandbox_endpoint: "http://#{hosts[0]}:80", } }.to_json)

      apicast_info = System::DomainInfo.apicast_info('3scale.net')
      assert apicast_info.staging
      assert apicast_info.production
    end
  end
end
