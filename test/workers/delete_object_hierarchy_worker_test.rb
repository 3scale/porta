# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @object = FactoryBot.create(:metric)
  end

  def test_perform
    ThinkingSphinx::Test.disable_real_time_callbacks!
    perform_enqueued_jobs do
      perform_expectations

      hierarchy_worker.perform_now(object)
    end
  end

  def test_success_callback_method
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(object, caller_worker_hierarchy, 'destroy')
    hierarchy_worker.new.on_success(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  def test_complete_callback_method
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(object, caller_worker_hierarchy, 'destroy')
    hierarchy_worker.new.on_complete(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  private

  attr_reader :object

  def perform_expectations; end

  def hierarchy_worker
    DeleteObjectHierarchyWorker
  end

  class AssociationUnknownPrimaryKeyTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'the error is not raised and the object is removed' do
      plan = FactoryBot.create(:application_plan)
      feature = FactoryBot.create(:feature)
      features_plan = plan.features_plans.create!(feature: feature)

      assert_difference(plan.features_plans.method(:count), -1) do
        perform_enqueued_jobs(except: SphinxIndexationWorker) { DeleteObjectHierarchyWorker.perform_now(feature) }
      end

      assert_raises(ActiveRecord::RecordNotFound) { feature.reload }
    end
  end

  class DeleteObjectHierarchyWorkerWhenDoesNotHaveAssociationsTest < ActiveSupport::TestCase
    def test_execute_success_when_empty_batch
      object = FactoryBot.create(:metric)
      worker = DeleteObjectHierarchyWorker.new
      worker.instance_variable_set(:@object, object)
      caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
      worker.instance_variable_set(:@caller_worker_hierarchy, caller_worker_hierarchy)
      worker.expects(:on_complete).with(anything, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
      worker.perform(object: object)
    end
  end

  class DeleteObjectHierarchyWorkerWhenObjectDoesNotExistAnymoreTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @object = FactoryBot.create(:simple_account)
      Rails.logger.stubs(:info)
    end

    attr_reader :object

    def test_perform_deserialization_error
      object.destroy!
      Rails.logger.expects(:info).with { |message| message.match(/DeleteObjectHierarchyWorker#perform raised ActiveJob::DeserializationError/) }
      perform_enqueued_jobs(except: SphinxIndexationWorker) { DeleteObjectHierarchyWorker.perform_later(object) }
    end

    def test_success_record_not_found
      object.destroy!
      Rails.logger.expects(:info).with("DeleteObjectHierarchyWorker#on_success raised ActiveRecord::RecordNotFound with message Couldn't find #{object.class} with 'id'=#{object.id}")
      DeleteObjectHierarchyWorker.new.on_success(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => %w[Hierarchy-TestClass-123]})
    end
  end

  class DeletePlanTest < DeleteObjectHierarchyWorkerTest
    setup do
      # ApplicationPlan setup
      @object = @plan = FactoryBot.create(:application_plan)
      @contract = FactoryBot.create(:application_contract, plan: @plan)
      @customized_plan = FactoryBot.create(:application_plan, original_id: @plan.id)
    end

    private

    attr_reader :plan, :contract, :customized_plan

    def perform_expectations
      DeletePlainObjectWorker.stubs(:perform_later)
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything, 'destroy')
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Plan.new({ id: customized_plan.id }, without_protection: true), anything, 'destroy')
    end

    class AccountPlanTest < DeletePlanTest
      def setup
        @object = @plan = FactoryBot.create(:account_plan)
        @contract = FactoryBot.create(:account_contract, plan: @plan)
        @customized_plan = FactoryBot.create(:account_plan, original_id: @plan.id)
      end
    end

    class ServicePlanTest < DeletePlanTest
      def setup
        @object = @plan = FactoryBot.create(:service_plan)
        @contract = FactoryBot.create(:service_contract, plan: @plan)
        @customized_plan = FactoryBot.create(:service_plan, original_id: @plan.id)
      end
    end
  end

  class DeleteServiceTest < DeleteObjectHierarchyWorkerTest
    setup do
      @object = @service = FactoryBot.create(:simple_service)

      @service_plan = service.service_plans.first
      @application_plan = FactoryBot.create(:application_plan, issuer: service)
      @metrics = service.metrics
      service.update_attribute :default_service_plan, service_plan
      service.update_attribute :default_application_plan, application_plan
      @api_docs_service = FactoryBot.create(:api_docs_service, service: service, account: service.account)

      @backend_api = FactoryBot.create(:backend_api, account: service.account)
      @backend_api_config = FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)
    end

    private

    attr_reader :service, :service_plan, :application_plan, :metrics, :api_docs_service, :backend_api, :backend_api_config

    def perform_expectations
      DeletePlainObjectWorker.stubs(:perform_later)
      DeleteObjectHierarchyWorker.stubs(:perform_later)

      [service_plan, application_plan].each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything, 'destroy')
      end
      metrics.each { |metric| DeleteObjectHierarchyWorker.expects(:perform_later).with(metric, anything, 'destroy') }
      DeleteObjectHierarchyWorker.expects(:perform_later).with(api_docs_service, anything, 'destroy')
      DeleteObjectHierarchyWorker.expects(:perform_later).with(service.proxy, anything, 'destroy')

      DeleteObjectHierarchyWorker.expects(:perform_later).with(backend_api_config, anything, 'destroy').once
      DeleteObjectHierarchyWorker.expects(:perform_later).with(backend_api, anything, 'destroy').never
    end
  end

  class DeleteMemberPermissionThroughUserTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def setup
      tenant = FactoryBot.create(:simple_provider)
      @member = FactoryBot.create(:member, account: tenant)
      @member_permission = FactoryBot.create(:member_permission, user: member)
    end

    attr_reader :member, :member_permission

    def test_perform
      ThinkingSphinx::Test.disable_real_time_callbacks!
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_now(member) }

      assert_raises(ActiveRecord::RecordNotFound) { member_permission.reload }
      assert_raises(ActiveRecord::RecordNotFound) { member.reload }
    end
  end

  class BackgroundAssociationListsTest < ActiveSupport::TestCase

    class DoubleObject

      def id
        1
      end

      def to_global_id
        'double/1'
      end

      def service
        Service.new({ id: 1}, without_protection: true)
      end
    end

    class DoubleWithBackgroundDestroyAssociation < DoubleObject

      include BackgroundDeletion
      self.background_deletion = { service: { action: :destroy, has_many: false } }
    end

    class DoubleWithBackgroundDeleteAssociation < DoubleObject

      include BackgroundDeletion
      self.background_deletion = { service: { action: :delete, has_many: false } }
    end

    def test_defined_background_destroy_associations
      double_object = DoubleWithBackgroundDestroyAssociation.new
      DeleteObjectHierarchyWorker.expects(:perform_later).with(double_object.service, anything, 'destroy').once
      DeleteObjectHierarchyWorker.perform_now(double_object)
    end

    def test_defined_background_delete_associations
      double_object = DoubleWithBackgroundDeleteAssociation.new
      DeleteObjectHierarchyWorker.expects(:perform_later).with(double_object.service, anything, 'delete').once
      DeleteObjectHierarchyWorker.perform_now(double_object)
    end
  end
end
