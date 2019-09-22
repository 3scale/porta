# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:simple_service)
  end

  attr_reader :service

  test 'complete success method' do
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(service, caller_worker_hierarchy)
    DeleteServiceHierarchyWorker.new.on_success(1, {'object_global_id' => service.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  test 'complete callback method' do
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(service, caller_worker_hierarchy)
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
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      [service_plan, application_plan, end_user_plan].each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything)
      end
      metrics.each { |metric| DeleteObjectHierarchyWorker.expects(:perform_later).with(metric, anything) }

      DeleteServiceHierarchyWorker.perform_now(service)
    end
  end

  test 'perform does not mark as deleted the backend api for a provider with the RU api as product' do
    Account.any_instance.stubs(provider_can_use?: true)
    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(true)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)

    DeleteServiceHierarchyWorker.perform_now(service)

    refute backend_api.reload.deleted?
  end

  test 'perform marks as deleted the backend api for a provider without the RU api as product' do
    Account.any_instance.stubs(provider_can_use?: false)
    Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    deleted_backend_api = FactoryBot.create(:backend_api, account: service.account, state: :deleted)
    FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)
    FactoryBot.create(:backend_api_config, service: service, backend_api: deleted_backend_api)

    DeleteServiceHierarchyWorker.perform_now(service)

    assert backend_api.reload.deleted?
    assert deleted_backend_api.reload.deleted?
  end
end
