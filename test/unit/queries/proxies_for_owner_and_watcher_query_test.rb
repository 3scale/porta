require 'test_helper'

class ProxiesForOwnerAndWatcherQueryTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
  end

  attr_reader :provider, :service

  class ProxiesForServiceOwnerAndWatcherQueryTest < ProxiesForOwnerAndWatcherQueryTest
    test 'it searches by service owner & filters by accessible only' do
      another_service, deleted_service = FactoryBot.create_list(:simple_service, 2, account: provider)
      deleted_service.mark_as_deleted!

      assert_equal [service.proxy.id], ProxiesForServiceOwnerAndWatcherQuery.call(owner: service).select(:id).map(&:id)
      assert_equal [another_service.proxy.id], ProxiesForServiceOwnerAndWatcherQuery.call(owner: another_service).select(:id).map(&:id)
      assert_empty ProxiesForServiceOwnerAndWatcherQuery.call(owner: deleted_service).select(:id).map(&:id)
    end
  end

  class ProxiesForProviderOwnerAndWatcherQueryTest < ProxiesForOwnerAndWatcherQueryTest
    test 'it searches by provider owner & filters by accessible only' do
      services = [service] | FactoryBot.create_list(:simple_service, 2, account: provider)
      services.last.mark_as_deleted!
      _service_of_another_provider = FactoryBot.create(:simple_service)

      assert_same_elements provider.accessible_services.map { |s| s.proxy.id },
                           ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider).select(:id).map(&:id)
    end

    test 'it filters by watcher permissions' do
      services = [service] | FactoryBot.create_list(:simple_service, 2, account: provider)

      admin = FactoryBot.create(:admin, account: provider)
      member_access_all_services = FactoryBot.create(:member, account: provider, admin_sections: ['partners'])
      member_access_all_services.update!(member_permission_service_ids: nil)
      member_access_some_services = FactoryBot.create(:member, account: provider, admin_sections: ['partners'])
      member_access_some_services.update!(member_permission_service_ids: services[0..1].map(&:id))
      member_with_sections_permissions_but_empty_services = FactoryBot.create(:member, account: provider, admin_sections: ['partners'])
      member_with_sections_permissions_but_empty_services.update!(member_permission_service_ids: '[]')

      rolling_update(:service_permissions, enabled: true)
      [admin, member_access_all_services].each do |user|
        assert_same_elements services.map { |s| s.proxy.id }, ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: user).select(:id).map(&:id)
      end
      assert_same_elements(services[0..1].map { |s| s.proxy.id },
                           ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: member_access_some_services).select(:id).map(&:id))
      assert_empty ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: member_with_sections_permissions_but_empty_services).select(:id).map(&:id)
      assert_same_elements services.map { |s| s.proxy.id }, ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: provider).select(:id).map(&:id)
      assert_same_elements services.map { |s| s.proxy.id }, ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: nil).select(:id).map(&:id)

      rolling_update(:service_permissions, enabled: false)
      [admin, member_access_all_services, member_access_some_services, member_with_sections_permissions_but_empty_services, provider, nil].each do |watcher|
        assert_same_elements services.map { |s| s.proxy.id }, ProxiesForProviderOwnerAndWatcherQuery.call(owner: provider, watcher: watcher).select(:id).map(&:id)
      end
    end
  end
end
