# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ProxyTest < ActiveSupport::TestCase
    class ResetProxyConfigChangeHistoryTest < ActiveSupport::TestCase
      setup do
        @providers = FactoryBot.create_list(:provider_account, 3)

        @proxy_with_legit_change = proxies.last
        @legit_change_date = 2.minutes.from_now.freeze
        proxy_with_legit_change.affecting_change_history.update_column(:updated_at, legit_change_date) # so change history of this proxy has been updated

        @providers << FactoryBot.create(:provider_account) # change history for the proxy associated with this account does not exist
        @proxy_without_change_history = proxies.last
        ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).delete_all
        @reset_date = Time.utc(1900, 1, 1).freeze
      end

      attr_reader :providers, :proxy_with_legit_change, :legit_change_date, :proxy_without_change_history, :reset_date

      test 'creates missing change history' do
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?
        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history'
        assert ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?
      end

      test 'resets change history of all providers whose proxy config is untouched' do
        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?

        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history'

        ProxyConfigAffectingChange.where(proxy: proxies.to_a.values_at(0, 1, 3)).each { |tracking_object| assert_equal reset_date, tracking_object.updated_at }
        assert_did_not_reset_proxy_with_legit_change
      end

      test 'resets change history of given account id' do
        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?

        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history', providers.last.id

        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        assert_equal reset_date, proxies.last.affecting_change_history.updated_at
      end

      test 'reset change history of legit tracking record is a no-op' do
        assert_did_not_reset_proxy_with_legit_change
        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history', providers[2].id
        assert_did_not_reset_proxy_with_legit_change
      end

      protected

      def proxies
        Proxy.where(service: Service.where(account: providers)).order(:id)
      end

      def assert_did_not_reset_proxies_without_legit_change
        ProxyConfigAffectingChange.where(proxy: proxies[0..1]).each { |tracking_object| assert tracking_object.created_at == tracking_object.updated_at }
      end

      def assert_did_not_reset_proxy_with_legit_change
        assert_equal legit_change_date.to_i, proxy_with_legit_change.affecting_change_history.updated_at.to_i
      end
    end

    class MigrateToConfigurationDriven < ActiveSupport::TestCase
      setup do
        @provider = FactoryBot.create(:simple_provider)

        services = [
          @hosted_apicast_v1_service_1 = create_service(account: provider, deployment_option: 'hosted', proxy: { apicast_configuration_driven: false }),
          @hosted_apicast_v1_service_2 = create_service(deployment_option: 'hosted', proxy: { apicast_configuration_driven: false }), # different provider
          @self_managed_apicast_v1_service = create_service(account: provider, deployment_option: 'self_managed', proxy: { apicast_configuration_driven: false }),
          @hosted_apicast_v2_service = create_service(account: provider, deployment_option: 'hosted') # configuration driven
        ]

        @services = Service.where(id: services)
      end

      attr_reader :provider, :services, :hosted_apicast_v1_service_1, :hosted_apicast_v1_service_2, :self_managed_apicast_v1_service, :hosted_apicast_v2_service

      test 'all services' do
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven'
        assert Proxy.where(service: services).all?(&:apicast_configuration_driven)
      end

      test 'selected service ids' do
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', selected_service_ids
        assert Proxy.where(service: selected_service_ids).all?(&:apicast_configuration_driven)
        refute hosted_apicast_v1_service_2.reload.proxy.apicast_configuration_driven # not in the list
      end

      test 'all hosted services' do
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'hosted'
        assert hosted_apicast_v1_service_1.reload.proxy.apicast_configuration_driven
        assert hosted_apicast_v1_service_2.reload.proxy.apicast_configuration_driven
        refute self_managed_apicast_v1_service.reload.proxy.apicast_configuration_driven # not hosted
      end

      test 'all self_managed services' do
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'self_managed'
        refute hosted_apicast_v1_proxies.any?(&:apicast_configuration_driven) # not self_managed
        assert self_managed_apicast_v1_service.reload.proxy.apicast_configuration_driven
      end

      test 'service selector specifying the deployment option and service ids' do
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', "self_managed,#{selected_service_ids}"
        assert self_managed_apicast_v1_service.reload.proxy.apicast_configuration_driven
        refute hosted_apicast_v1_service_1.reload.proxy.apicast_configuration_driven # not self_managed
        refute hosted_apicast_v1_service_2.reload.proxy.apicast_configuration_driven # not in the list
      end

      test 'deploy to staging' do
        hosted_apicast_v1_proxies.update_all(deployed_at: 1.day.ago)
        hosted_apicast_v1_proxies.each { |proxy| ProxyDeploymentService.expects(:call).with(proxy, environment: :staging) }
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'hosted'
      end

      test 'deploy to staging and production' do
        hosted_apicast_v1_proxies.update_all(deployed_at: 1.day.ago)
        Account.providers.where(id: hosted_apicast_v1_proxies.map(&:provider)).update_all(hosted_proxy_deployed_at: 1.second.from_now) # small trick to mock the proxy been deployed to production sandbox proxy already
        hosted_apicast_v1_proxies.each do |proxy|
          ProxyDeploymentService.expects(:call).with(proxy, environment: :staging)
          ProxyDeploymentService.expects(:call).with(proxy, environment: :production)
        end
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'hosted', 'staging,production'
      end

      test 'updating the proxy endpoints' do
        assert hosted_apicast_v1_proxies.all? { |proxy| proxy.endpoint =~ /apicast\.io/ }
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'hosted', true
        assert hosted_apicast_v1_proxies.all? { |proxy| proxy.endpoint =~ /apicast\.dev/ }
      end

      test 'without updating the proxy endpoints' do
        assert hosted_apicast_v1_proxies.all? { |proxy| proxy.endpoint =~ /apicast\.io/ }
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven', 'hosted'
        assert hosted_apicast_v1_proxies.all? { |proxy| proxy.endpoint =~ /apicast\.io/ }
      end

      test 'excludes accounts scheduled for deletion' do
        hosted_apicast_v1_service_2.account.update_column(:state, 'scheduled_for_deletion')
        execute_rake_task 'proxy.rake', 'proxy:migrate_to_configuration_driven'
        assert Proxy.where(service: services.where(account: provider)).all?(&:apicast_configuration_driven)
        refute hosted_apicast_v1_service_2.proxy.reload.apicast_configuration_driven
      end

      protected

      def create_service(attributes = {})
        service = FactoryBot.build(:simple_service, attributes.except(:proxy))
        service.proxy = FactoryBot.build(:simple_proxy, service: service, **attributes.fetch(:proxy, {}))
        service.save!
        service
      end

      def selected_service_ids
        [hosted_apicast_v1_service_1, self_managed_apicast_v1_service].map(&:id).join(',')
      end

      def hosted_apicast_v1_proxies
        Proxy.where(apicast_configuration_driven: false, service: services.where(deployment_option: 'hosted'))
      end
    end
  end
end
