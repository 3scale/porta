# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @object = FactoryBot.create(:metric)
  end

  def test_perform
    perform_enqueued_jobs do
      perform_expectations

      DeleteObjectHierarchyWorker.delete_later(object)
    end
  end

  private

  attr_reader :object

  def perform_expectations; end

  class DeletingOrderCheck < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    class TracingDeleteObjectHierarchyWorker < DeleteObjectHierarchyWorker
      def self.trace
        @trace ||= []
      end

      private def handle_hierarchy_entry(entry)
        self.class.trace << entry
        super
      end
    end

    test "basic order test" do
      metric = FactoryBot.create(:metric)
      pricing_rule = FactoryBot.create(:pricing_rule, metric: metric)

      perform_enqueued_jobs do
        TracingDeleteObjectHierarchyWorker.delete_later(metric)
      end

      exp = %W[
        Association-Metric-#{metric.id}:proxy_rules
        Association-Metric-#{metric.id}:plan_metrics
        Association-Metric-#{metric.id}:usage_limits
        Association-Metric-#{metric.id}:pricing_rules
        Plain-PricingRule-#{pricing_rule.id}
        Association-Metric-#{metric.id}:pricing_rules
        Plain-Metric-#{metric.id}
        ]

      assert_equal exp, TracingDeleteObjectHierarchyWorker.trace
    end
  end

  class ReschedulingTest < ActiveSupport::TestCase
    test "will reschedule if timeout is reached" do
      TODO
    end
  end

  class AssociationUnknownPrimaryKeyTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'the error is not raised and the object is removed' do
      plan = FactoryBot.create(:application_plan)
      feature = FactoryBot.create(:feature)
      features_plan = plan.features_plans.create!(feature: feature)

      assert_difference(plan.features_plans.method(:count), -1) do
        perform_enqueued_jobs { DeleteObjectHierarchyWorker.delete_later(feature) }
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
      System::ErrorReporting.stubs(:report_error)
    end

    attr_reader :object

    test "compatibility perform deserialization error" do
      object.destroy!
      System::ErrorReporting.expects(:report_error).with { _1.is_a? ActiveJob::DeserializationError }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later(object) }
    end

    test "compatibility perform error with hierarchy" do
      object.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later({}, ["Hierarchy-Account-#{object.id}"]) }
    end

    test "success when record not found" do
      object.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later("Plain-#{object.class}-#{object.id}") }
    end

    test "deleting records that mixed do not exist" do
      account = object
      service, other_service = FactoryBot.create_list(:simple_service, 2, account:)
      service.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }.twice
      perform_enqueued_jobs {
        DeleteObjectHierarchyWorker.perform_later(
          "Plain-#{object.class}-#{object.id}",
          "Plain-Service-#{service.id}",
          "Association-Service-#{service.id}:metrics",
          "Plain-Service-#{other_service.id}",
        )
      }

      assert_raises(ActiveRecord::RecordNotFound) { other_service.reload }
      assert_raises(ActiveRecord::RecordNotFound) { account.reload }
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

  class DeleteServiceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

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

    test "delete when destroyable" do
      FactoryBot.create(:service, account: service.account) # just a second service to make first destroyable
      cinstance = FactoryBot.create(:cinstance, plan: application_plan)
      limit_alerts = FactoryBot.create_list(:limit_alert, 4, cinstance:, account: cinstance.user_account)
      perform_enqueued_jobs(queue: "deletion") do
        service.mark_as_deleted!
      end

      [service, service_plan, application_plan, *metrics.to_a, api_docs_service, service.proxy, backend_api_config, *limit_alerts].each do |object|
        assert_raise(ActiveRecord::RecordNotFound) { object.reload }
      end

      assert backend_api.reload
    end

    test "delete non-destroyable fails" do
      assert_raise(ActiveRecord::RecordNotDestroyed) do
        perform_enqueued_jobs(queue: "deletion") do
          DeleteObjectHierarchyWorker.perform_later("Plain-Service-#{service.id}")
        end
      end

      assert service.reload
    end

    test "delete default service as association" do
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.perform_later("Plain-Account-#{service.account_id}", "Plain-Service-#{service.id}")
      end

      assert_raise(ActiveRecord::RecordNotFound) { service.reload }
    end

    private

    attr_reader :service, :service_plan, :application_plan, :metrics, :api_docs_service, :backend_api, :backend_api_config
  end

  class DeleteAccountTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @provider = FactoryBot.create(:provider_account, :with_a_buyer)
    end

    test "delete succeeds" do
      provider2 = FactoryBot.create(:provider_account, :with_a_buyer)

      buyer1 = @provider.buyers.first
      buyer2 = FactoryBot.create(:buyer_account, provider_account: @provider)
      @provider.schedule_for_deletion!
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later buyer1
      end
      assert_raise(ActiveRecord::RecordNotFound) { buyer1.reload }
      buyer2.reload

      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later @provider
      end

      assert_raise(ActiveRecord::RecordNotFound) { @provider.reload }
      assert_raise(ActiveRecord::RecordNotFound) { buyer2.reload }

      provider2.reload
      assert_equal 1, provider2.buyers.count
    end

    test "delete with a payment_gateway_setting" do
      pgs = FactoryBot.create(:payment_gateway_setting, account: @provider)
      @provider.schedule_for_deletion!
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later @provider
      end

      assert_raise(ActiveRecord::RecordNotFound) { @provider.reload }
      assert_raise(ActiveRecord::RecordNotFound) { pgs.reload }
    end

    test "account is not deleted when not scheduled" do
      buyer = @provider.buyers.first
      perform_enqueued_jobs(queue: "deletion") do
        assert_raises { DeleteObjectHierarchyWorker.delete_later buyer }
        assert_raises { DeleteObjectHierarchyWorker.delete_later @provider }
      end
      assert @provider.reload
      assert buyer.reload
    end
  end

  class WorkerCompatibilityTest < ActiveSupport::TestCase
    test "perform with hierarchy" do
      TODO
    end

    test "perform without hierarchy" do
      TODO
    end

    test "perform without hierarchy and without object" do
      TODO
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
