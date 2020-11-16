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
    disable_transactional_fixtures!

    test 'Search of only the newest version should be found' do
      environment = 'sandbox' # It can be either 'sandbox' or 'production' and for this test it does not matter, but the assertions at the end must be consistent

      service = FactoryBot.create(:simple_service, :with_default_backend_api)

      old_hosts = %w[3scale.net example.com]
      new_hosts = %w[example.org 3scale.localhost]

      proxy_config_old, proxy_config_new = [old_hosts, new_hosts].map do |hosts|
        FactoryBot.create(:proxy_config, environment: environment, proxy: service.proxy, content: content(*hosts))
      end

      assert proxy_config_old.version < proxy_config_new.version
      assert_equal [environment], ProxyConfig.all.distinct.pluck(:environment) # All proxy configs environment field are 'sandbox', which means that there can never be a production endpoint found

      old_hosts.each do |host|
        apicast_info = System::DomainInfo.apicast_info(host)
        refute apicast_info.staging
        refute apicast_info.production
      end

      newest_staging_host, newest_production_host = new_hosts
      apicast_info = System::DomainInfo.apicast_info(newest_staging_host)
      assert apicast_info.staging
      refute apicast_info.production
      apicast_info = System::DomainInfo.apicast_info(newest_production_host)
      refute apicast_info.staging
      refute apicast_info.production
    end

    test 'Search of the same environment and version but different proxy_id' do
      environment = 'sandbox' # It can be either 'sandbox' or 'production' and for this test it does not matter, but the assertions at the end must be consistent

      staging_host_1, production_host_1 = %w[3scale.net example.com]
      staging_host_2, production_host_2 = %w[example.org 3scale.localhost]

      hosts_list = [
        [staging_host_1, production_host_1],
        [staging_host_2, production_host_2]
      ]

      proxy_config_proxy_1, proxy_config_proxy_2 = hosts_list.map do |hosts|
        FactoryBot.create(:proxy_config, environment: environment, content: content(*hosts))
      end

      assert_equal proxy_config_proxy_1.version, proxy_config_proxy_2.version
      refute_equal proxy_config_proxy_1.proxy_id, proxy_config_proxy_2.proxy_id
      assert_equal [environment], ProxyConfig.all.distinct.pluck(:environment) # All proxy configs environment field are 'sandbox', which means that there can never be a production endpoint found

      apicast_info = System::DomainInfo.apicast_info(staging_host_1)
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info(production_host_1)
      refute apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info(staging_host_2)
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info(production_host_2)
      refute apicast_info.staging
      refute apicast_info.production
    end

    test 'Same service and version, different environment. Both should be found' do
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

    test 'staging false, production true & staging true, production false. Latest versions for the same service' do
      services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api)

      hosts_list = [
        %w[api.example.org api.3scale.net],
        %w[api.3sca.net api.example.org],
        %w[api.3scale.net api.3sca.net]
      ]

      proxy_configs_by_service = services.map do |service|
        hosts_list.map do |hosts|
          ProxyConfig::ENVIRONMENTS.map do |env|
            FactoryBot.create(:proxy_config,
            proxy: service.proxy,
            environment: env,
            content: content(*hosts))
          end
        end.flatten
      end

      # Ensure that the versions are saved in the right order
      environments_amount = ProxyConfig::ENVIRONMENTS.size
      proxy_configs_by_service.each do |proxy_configs_of_service|
        proxy_configs_of_service.each_with_index do |config, index|
          next if index < environments_amount
          assert config.version > proxy_configs_of_service[index - environments_amount].version
        end
      end

      apicast_info = System::DomainInfo.apicast_info('api.3scale.net')
      assert apicast_info.staging
      refute apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('api.3sca.net')
      refute apicast_info.staging
      assert apicast_info.production

      apicast_info = System::DomainInfo.apicast_info('api.example.org')
      refute apicast_info.staging
      refute apicast_info.production
    end

    private

    def content(sandbox_host, production_host)
      {
        proxy: {
          hosts: [sandbox_host, production_host],
          sandbox_endpoint: "http://#{sandbox_host}:80",
          endpoint: "http://#{production_host}:80"
        }
      }.to_json
    end

  end
end
