# frozen_string_literal: true

require 'test_helper'

class Backend::StorageSyncTest < ActiveSupport::TestCase

  setup do
    @provider = FactoryGirl.create(:provider_account)
    @backend_storage_sync = Backend::StorageSync.new(provider)
  end

  attr_reader :provider, :backend_storage_sync

  test 'revoke access when the provider is scheduled for deletion' do
    provider.schedule_for_deletion!
    backend_storage_sync.expects(:update_backend).with(:deactivate)
    backend_storage_sync.sync_provider
  end

  test 'rewrite when the provider is not scheduled for deletion' do
    refute provider.scheduled_for_deletion?
    backend_storage_sync.expects(:update_backend).with(:activate)
    backend_storage_sync.sync_provider
  end

  test 'enqueues again if it was scheduled for deletion but not anymore' do
    backend_storage_sync.stubs(:update_backend)
    Account.any_instance.expects(:scheduled_for_deletion?).times(2).returns(true).then.returns(false)
    BackendProviderSyncWorker.expects(:enqueue).with(provider.id)
    backend_storage_sync.sync_provider
  end

  test 'enqueues again if it was not scheduled for deletion but it is at the end' do
    backend_storage_sync.stubs(:update_backend)
    Account.any_instance.expects(:scheduled_for_deletion?).times(2).returns(false).then.returns(true)
    BackendProviderSyncWorker.expects(:enqueue).with(provider.id)
    backend_storage_sync.sync_provider
  end

  test 'provider_sync deactivates all the providers\' services when the provider is scheduled for deletion' do
    FactoryGirl.create(:simple_service, account: provider)
    provider.schedule_for_deletion!

    mock_update_backend_services provider.services.select(:id), :deactivate

    backend_storage_sync.sync_provider
  end

  test 'provider_sync activates all the providers\' services when the provider is not scheduled for deletion' do
    FactoryGirl.create(:simple_service, account: provider)
    refute provider.scheduled_for_deletion?

    mock_update_backend_services provider.services.select(:id), :activate

    backend_storage_sync.sync_provider
  end

  private

  def mock_update_backend_services(services, state_action)
    services_update_backend_services = services.map do |service|
      backend_service = ServiceUpdateBackendService.new service
      backend_service.expects(:update_state!).with(state_action)
      backend_service
    end

    ServiceUpdateBackendService.expects(:new)
        .times(services.size)
        .with { |service_arg| services.pluck(:id).include? service_arg.id }
        .returns(*services_update_backend_services)
  end

end
