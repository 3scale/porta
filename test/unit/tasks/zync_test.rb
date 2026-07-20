require 'test_helper'

module Tasks
  class ZyncTest < ActiveSupport::TestCase
    setup do
      FactoryBot.create(:provider_account)
    end

    class DomainsSyncTest < ZyncTest
      test 'resync provider domains' do
        active_providers.each { |account| ZyncResyncEvent.expects(:create_and_publish!).with(account, provider_id: account.id) }
        execute_rake_task 'zync.rake', 'zync:resync:provider_domains'
      end

      test 'resync proxy domains' do
        active_proxies.each { |proxy| ZyncResyncEvent.expects(:create_and_publish!).with(proxy, provider_id: proxy.service.account_id, service_id: proxy.service_id) }
        execute_rake_task 'zync.rake', 'zync:resync:proxy_domains'
      end

      private

      def active_providers
        Account.providers_with_master.without_suspended.without_deleted
      end

      def active_proxies
        Proxy.eager_load(service: :account).merge(active_providers)
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
      end

      test 'full resync' do
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync includes suspended providers' do
        @providers.first.suspend!
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync with suspended PROVIDER_ID' do
        @providers.first.suspend!
        ENV['PROVIDER_ID'] = @providers.first.id.to_s
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
      ensure
        ENV.delete('PROVIDER_ID')
      end

      test 'full resync excludes scheduled for deletion providers' do
        @providers.first.schedule_for_deletion!
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
      end

      test 'full resync with PROVIDER_ID' do
        ENV['PROVIDER_ID'] = @providers.first.id.to_s
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
      ensure
        ENV.delete('PROVIDER_ID')
      end

      private

      def load_collections
        active = Account.providers_with_master
        active = active.where(id: ENV['PROVIDER_ID']) if ENV['PROVIDER_ID']
        @all_accounts = active.to_a
        @all_services = Service.joins(:account).merge(active).to_a
        @all_proxies = Proxy.eager_load(:service).joins(service: :account).merge(active).to_a
        @all_cinstances = Cinstance.eager_load(:service).joins(service: :account).merge(active).to_a
      end

      def expect_resync_events
        @all_accounts.each { |account| ZyncResyncEvent.expects(:create_and_publish!).with(account, provider_id: account.id) }
        @all_services.each { |service| ZyncResyncEvent.expects(:create_and_publish!).with(service, provider_id: service.account_id) }
        @all_proxies.each { |proxy| ZyncResyncEvent.expects(:create_and_publish!).with(proxy, provider_id: proxy.service.account_id, service_id: proxy.service_id) }
        @all_cinstances.each { |cinstance| ZyncResyncEvent.expects(:create_and_publish!).with(cinstance, provider_id: cinstance.service.account_id, service_id: cinstance.service_id) }
      end
    end
  end
end
