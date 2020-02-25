# frozen_string_literal: true

require 'test_helper'

class DeleteServiceHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @service = FactoryBot.create(:simple_service)
  end

  attr_reader :service

  test 'complete success method' do
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(service, caller_worker_hierarchy, 'destroy')
    DeleteServiceHierarchyWorker.new.on_success(1, {'object_global_id' => service.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  test 'complete callback method' do
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(service, caller_worker_hierarchy, 'destroy')
    DeleteServiceHierarchyWorker.new.on_complete(1, {'object_global_id' => service.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  test 'perform destroys the associations in background' do
    DeleteObjectHierarchyWorker.stubs(:perform_later)

    service_plan = service.service_plans.first
    application_plan = FactoryBot.create(:application_plan, issuer: service)
    end_user_plan = FactoryBot.create(:end_user_plan, service: service)
    metrics = service.metrics
    service.update_attribute :default_service_plan, service_plan
    service.update_attribute :default_application_plan, application_plan
    api_docs_service = FactoryBot.create(:api_docs_service, service: service, account: service.account)

    perform_enqueued_jobs do
      [service_plan, application_plan, end_user_plan].each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything, 'destroy')
      end
      metrics.each { |metric| DeleteObjectHierarchyWorker.expects(:perform_later).with(metric, anything, 'destroy') }
      DeleteObjectHierarchyWorker.expects(:perform_later).with(api_docs_service, anything, 'destroy')

      DeleteServiceHierarchyWorker.perform_now(service)
    end
  end

  class BackendApisAssociatedTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def setup
      @service = FactoryBot.create(:simple_service)
      @backend_api = FactoryBot.create(:backend_api, account: service.account)
      @backend_api_config = FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)
      ::Logic::RollingUpdates.stubs(enabled?: true)
      ::Logic::RollingUpdates.stubs(skipped?: false)
    end

    attr_reader :service, :backend_api, :backend_api_config

    test 'does not destroy the backend apis for a provider with the RU api as product' do
      rolling_update(:api_as_product, enabled: true)

      perform_enqueued_jobs { DeleteServiceHierarchyWorker.perform_now(service.reload) }

      refute BackendApiConfig.exists?(backend_api_config.id), "BackendApiConfig ##{backend_api_config.id} should have been destroyed"
      assert BackendApi.exists?(backend_api.id), "BackendApi ##{backend_api.id} should have not been destroyed"
    end

    test 'destroys backend apis for a provider without the RU api as product' do
      rolling_update(:api_as_product, enabled: false)

      perform_enqueued_jobs { DeleteServiceHierarchyWorker.perform_now(service.reload) }

      refute BackendApiConfig.exists?(backend_api_config.id), "BackendApiConfig ##{backend_api_config.id} should have been destroyed"
      refute BackendApi.exists?(backend_api.id), "BackendApi ##{backend_api.id} should have been destroyed"
    end
  end
end
