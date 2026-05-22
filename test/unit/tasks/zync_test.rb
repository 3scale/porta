require 'test_helper'

module Tasks
  class ZyncTest < ActiveSupport::TestCase
    setup do
      FactoryBot.create(:provider_account)
    end

    class DomainsSyncTest < ZyncTest
      test 'resync provider domains' do
        Account.providers_with_master.each { |account| Domains::ProviderDomainsChangedEvent.expects(:create_and_publish!).with(account) }
        execute_rake_task 'zync.rake', 'zync:resync:provider_domains'
      end

      test 'resync proxy domains' do
        Service.all.each { |service| Domains::ProxyDomainsChangedEvent.expects(:create_and_publish!).with(service.proxy) }
        execute_rake_task 'zync.rake', 'zync:resync:proxy_domains'
      end
    end

    class FullSyncTest < ZyncTest
      setup do
        @providers = FactoryBot.create_list(:provider_account, 3)

        @providers.each do |provider|
          services = FactoryBot.create_list(:service, 2, account: provider)
          services.each do |service|
            plan = FactoryBot.create(:application_plan, issuer: service)
            FactoryBot.create_list(:cinstance, 3, plan: plan, service: service)
          end
        end

        @all_accounts = Account.providers_with_master.without_suspended.without_deleted.to_a
        @all_services = Service.where(account: @all_accounts).to_a
        @all_cinstances = Cinstance.where(service: @all_services).to_a
      end

      test 'full resync' do
        expect_full_resync_events(@all_accounts, @all_services, @all_cinstances)
        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync excludes suspended providers' do
        suspended_provider = @providers.first
        suspended_provider.suspend!

        excluded_services = Service.where(account: suspended_provider).to_a
        excluded_cinstances = Cinstance.where(service: excluded_services).to_a
        expect_no_resync_events(suspended_provider, excluded_services, excluded_cinstances)

        remaining_accounts = @all_accounts.reject { |a| a.id == suspended_provider.id }
        remaining_services = @all_services.reject { |s| s.account_id == suspended_provider.id }
        remaining_cinstances = @all_cinstances.reject { |c| excluded_services.map(&:id).include?(c.service_id) }
        expect_full_resync_events(remaining_accounts, remaining_services, remaining_cinstances)

        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync excludes scheduled for deletion providers' do
        deleted_provider = @providers.first
        deleted_provider.schedule_for_deletion!

        excluded_services = Service.where(account: deleted_provider).to_a
        excluded_cinstances = Cinstance.where(service: excluded_services).to_a
        expect_no_resync_events(deleted_provider, excluded_services, excluded_cinstances)

        remaining_accounts = @all_accounts.reject { |a| a.id == deleted_provider.id }
        remaining_services = @all_services.reject { |s| s.account_id == deleted_provider.id }
        remaining_cinstances = @all_cinstances.reject { |c| excluded_services.map(&:id).include?(c.service_id) }
        expect_full_resync_events(remaining_accounts, remaining_services, remaining_cinstances)

        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync with PROVIDER_ID' do
        provider = @providers.first
        provider_services = @all_services.select { |s| s.account_id == provider.id }
        provider_cinstances = @all_cinstances.select { |c| provider_services.map(&:id).include?(c.service_id) }

        expect_full_resync_events([provider], provider_services, provider_cinstances)

        ENV['PROVIDER_ID'] = provider.id.to_s
        execute_rake_task 'zync.rake', 'zync:resync:full'
      ensure
        ENV.delete('PROVIDER_ID')
      end

      private

      def expect_full_resync_events(accounts, services, cinstances)
        accounts.each { |account| Domains::ProviderDomainsChangedEvent.expects(:create_and_publish!).with(account) }
        services.each do |service|
          OIDC::ServiceChangedEvent.expects(:create_and_publish!).with(service)
          Domains::ProxyDomainsChangedEvent.expects(:create_and_publish!).with(service.proxy)
          OIDC::ProxyChangedEvent.expects(:create_and_publish!).with(service.proxy)
        end
        cinstances.each { |cinstance| Applications::ApplicationUpdatedEvent.expects(:create_and_publish!).with(cinstance) }
      end

      def expect_no_resync_events(account, services, cinstances)
        Domains::ProviderDomainsChangedEvent.expects(:create_and_publish!).with(account).never
        services.each do |service|
          OIDC::ServiceChangedEvent.expects(:create_and_publish!).with(service).never
          Domains::ProxyDomainsChangedEvent.expects(:create_and_publish!).with(service.proxy).never
          OIDC::ProxyChangedEvent.expects(:create_and_publish!).with(service.proxy).never
        end
        cinstances.each { |cinstance| Applications::ApplicationUpdatedEvent.expects(:create_and_publish!).with(cinstance).never }
      end
    end
  end
end
