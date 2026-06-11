require 'test_helper'

module Tasks
  class ZyncTest < ActiveSupport::TestCase
    setup do
      FactoryBot.create(:provider_account)
    end

    class DomainsSyncTest < ZyncTest
      test 'resync provider domains' do
        active_providers.each { |account| ZyncEvent.expects(:create_and_publish!).with(instance_of(ResyncEvent), account) }
        execute_rake_task 'zync.rake', 'zync:resync:provider_domains'
      end

      test 'resync proxy domains' do
        active_proxies.each { |proxy| ZyncEvent.expects(:create_and_publish!).with(instance_of(ResyncEvent), proxy) }
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

      test 'full resync excludes suspended providers' do
        @providers.first.suspend!
        load_collections
        expect_resync_events
        execute_rake_task 'zync.rake', 'zync:resync:full'
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
        if (provider_id = ENV['PROVIDER_ID'])
          active = active.where(id: provider_id)
        else
          active = active.without_suspended.without_deleted
        end
        @all_accounts = active.to_a
        @all_services = Service.joins(:account).merge(active).to_a
        @all_proxies = Proxy.eager_load(service: :account).merge(active).to_a
        @all_cinstances = Cinstance.eager_load(service: :account).merge(active).to_a
      end

      def expect_resync_events
        (@all_accounts + @all_services + @all_proxies + @all_cinstances).each do |model|
          ZyncEvent.expects(:create_and_publish!).with(instance_of(ResyncEvent), model)
        end
      end
    end
  end
end
