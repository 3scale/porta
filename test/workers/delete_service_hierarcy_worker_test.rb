# frozen_string_literal: true

require 'test_helper'

class DeleteServiceHierarchyWorkerTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:simple_service)
    DeleteObjectHierarchyWorker.stubs(:perform_later)
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
    service_plan = service.service_plans.first
    application_plan = FactoryBot.create(:application_plan, :issuer => service)
    end_user_plan = FactoryBot.create(:end_user_plan, service: service)
    metrics = service.metrics
    service.update_attribute :default_service_plan, service_plan
    service.update_attribute :default_application_plan, application_plan

    Sidekiq::Testing.inline! do
      [service_plan, application_plan, end_user_plan].each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything, 'destroy')
      end
      metrics.each { |metric| DeleteObjectHierarchyWorker.expects(:perform_later).with(metric, anything, 'destroy') }

      DeleteServiceHierarchyWorker.perform_now(service)
    end
  end

  test 'does not destroy the backend apis for a provider with the RU api as product' do
    Account.any_instance.stubs(provider_can_use?: true)
    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(true)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)

    DeleteObjectHierarchyWorker.expects(:perform_later).with(service.backend_api_configs.first!, anything, 'destroy').once
    DeleteObjectHierarchyWorker.expects(:perform_later).with(backend_api, anything, 'destroy').never

    Sidekiq::Testing.inline! { DeleteServiceHierarchyWorker.perform_now(service) }

    assert BackendApi.exists?(backend_api.id)
  end

  test 'destroys backend apis for a provider without the RU api as product' do
    Account.any_instance.stubs(provider_can_use?: false)
    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)

    DeleteObjectHierarchyWorker.expects(:perform_later).with(service.backend_api_configs.first!, anything, 'destroy').once
    DeleteObjectHierarchyWorker.expects(:perform_later).with(backend_api, anything, '').once

    Sidekiq::Testing.inline! { DeleteServiceHierarchyWorker.perform_now(service) }
  end
end
