# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  setup do
    @object = FactoryBot.create(:metric)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      perform_expectations

      hierarchy_worker.perform_now(object)
    end
  end

  def test_success_callback_method
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(object, caller_worker_hierarchy)
    hierarchy_worker.new.on_success(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  def test_complete_callback_method
    caller_worker_hierarchy = %w[HTestClass123 HTestClass1123]
    DeletePlainObjectWorker.expects(:perform_later).with(object, caller_worker_hierarchy)
    hierarchy_worker.new.on_complete(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy})
  end

  private

  attr_reader :object

  def perform_expectations; end

  def hierarchy_worker
    DeleteObjectHierarchyWorker
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
    setup do
      @object = FactoryBot.create(:simple_account)
      Rails.logger.stubs(:info)
    end

    attr_reader :object

    def test_perform_deserialization_error
      object.destroy!
      Rails.logger.expects(:info).with { |message| message.match(/DeleteObjectHierarchyWorker#perform raised ActiveJob::DeserializationError/) }
      Sidekiq::Testing.inline! { DeleteObjectHierarchyWorker.perform_later(object) }
    end

    def test_success_record_not_found
      object.destroy!
      Rails.logger.expects(:info).with("DeleteObjectHierarchyWorker#on_success raised ActiveRecord::RecordNotFound with message Couldn't find #{object.class} with 'id'=#{object.id}")
      DeleteObjectHierarchyWorker.new.on_success(1, {'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => %w[Hierarchy-TestClass-123]})
    end
  end

  class DeleteServiceHierarchyTest < DeleteObjectHierarchyWorkerTest
    setup do
      @object = @service = FactoryBot.create(:service)
      @service_plan = service.service_plans.first
      @application_plan = FactoryBot.create(:application_plan, :issuer => service)
      @end_user_plan = FactoryBot.create(:end_user_plan, service: service)
      @metrics = service.metrics
      service.update_attribute :default_service_plan, @service_plan
      service.update_attribute :default_application_plan, @application_plan
    end

    private

    attr_reader :service, :service_plan, :application_plan, :end_user_plan, :metrics

    def perform_expectations
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      [service_plan, application_plan, end_user_plan].each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything)
      end
      metrics.each { |metric| DeleteObjectHierarchyWorker.expects(:perform_later).with(metric, anything) }
    end
  end

  class DeleteAccountHierarchyTest < DeleteObjectHierarchyWorkerTest
    setup do
      @object = @provider = FactoryBot.create(:provider_account)
      @provider.schedule_for_deletion!

      non_default_service = FactoryBot.create(:service, account: provider)
      non_default_service.stubs(:default?).returns(false)
      @services = [provider.services.default, non_default_service]
      @account_plan = provider.account_plans.default

      FactoryBot.create(:service_contract, user_account: provider)
      FactoryBot.create(:account_contract, user_account: provider)
      FactoryBot.create(:application_contract, user_account: provider)
      @contracts = provider.reload.contracts

      @buyers = FactoryBot.create_list(:buyer_account, 2, provider_account: provider)
      @users = provider.users
    end

    private

    attr_reader :provider, :services, :account_plan, :buyers, :contracts, :users

    def hierarchy_worker
      DeleteAccountHierarchyWorker
    end

    def perform_expectations
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      (users + services).each do |association|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything)
      end
      buyers.each { |buyer| DeleteAccountHierarchyWorker.expects(:perform_later).with(buyer, anything) }
      contracts.each { |contract| DeleteObjectHierarchyWorker.expects(:perform_later).with(contract, anything) }
      DeleteObjectHierarchyWorker.expects(:perform_later).with(account_plan, anything)
    end

    test 'does not perform if wrong state' do
      provider.update_column(:state, 'approved')
      DeleteObjectHierarchyWorker.expects(:perform_later).never

      DeleteAccountHierarchyWorker.perform_now(provider)
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
      [contract, customized_plan].each { |association| DeleteObjectHierarchyWorker.expects(:perform_later).with(association, anything) }
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
end
