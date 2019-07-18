# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  setup do
    @object = FactoryBot.create(:metric)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      perform_expectations

      hierarchy_worker.perform_now(object, caller_hierarchy)
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

  def caller_hierarchy
    []
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

  class DeletePaymentSettingTest < DeleteObjectHierarchyWorkerTest
    def setup
      tenant = FactoryBot.create(:simple_provider)
      @object = FactoryBot.create(:payment_gateway_setting, account: tenant)
      @buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: tenant)
    end

    attr_reader :buyers

    def perform_expectations
      DeletePlainObjectWorker.stubs(:perform_later)
      DeleteObjectHierarchyWorker.stubs(:perform_later)

      buyers.each { |buyer| DeleteObjectHierarchyWorker.stubs(:perform_later).with(buyer, anything) }
    end

    def hierarchy_worker
      DeletePaymentSettingHierarchyWorker
    end

    def caller_hierarchy
      ["Hierarchy-Account-#{object.account_id}"]
    end

    test 'it does not perform for the buyers if it is not destroyed by the provider association' do
      DeleteAccountHierarchyWorker.expects(:perform_later).never

      Sidekiq::Testing.inline! { DeletePaymentSettingHierarchyWorker.perform_now(object, []) }

      @buyers.each { |buyer| assert buyer.reload }
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
      @payment_setting = FactoryBot.create(:payment_gateway_setting, account: provider)
    end

    private

    attr_reader :provider, :services, :account_plan, :buyers, :contracts, :users, :payment_setting

    def hierarchy_worker
      DeleteAccountHierarchyWorker
    end

    def perform_expectations
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      users.each { |user| DeleteObjectHierarchyWorker.expects(:perform_later).with(user, anything) }
      services.each { |service| DeleteServiceHierarchyWorker.expects(:perform_later).with(service, anything) }
      buyers.each { |buyer| DeleteAccountHierarchyWorker.expects(:perform_later).with(buyer, anything) }
      contracts.each do |contract|
        DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything)
      end
      DeleteObjectHierarchyWorker.expects(:perform_later).with(account_plan, anything)
      DeletePaymentSettingHierarchyWorker.expects(:perform_later).with(payment_setting, anything)
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
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything)
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Plan.new({ id: customized_plan.id }, without_protection: true), anything)
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

  class DeleteMemberPermissionThroughUserTest < ActiveSupport::TestCase
    def setup
      tenant = FactoryBot.create(:simple_provider)
      @member = FactoryBot.create(:member, account: tenant)
      @member_permission = FactoryBot.create(:member_permission, user: member)
    end

    attr_reader :member, :member_permission

    def test_perform
      Sidekiq::Testing.inline! { DeleteObjectHierarchyWorker.perform_now(member) }

      assert_raises(ActiveRecord::RecordNotFound) { member_permission.reload }
      assert_raises(ActiveRecord::RecordNotFound) { member.reload }
    end
  end
end
