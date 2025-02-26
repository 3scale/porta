# frozen_string_literal: true

require 'test_helper'
#TODO
class DeletePlainObjectWorkerTest < ActiveSupport::TestCase
  class DestroyableObjectsTest < DeletePlainObjectWorkerTest
    def setup
      factory_names = %i[simple_provider service application_plan metric]
      @objects = factory_names.map { |factory_name| FactoryBot.create(factory_name) }
    end

    attr_reader :objects

    def test_destroy
      object_1 = objects.first
      object_2 = objects.second

      DeletePlainObjectWorker.perform_now(object_1, %w[HTestClass123 HTestClass1123])
      assert_raise(ActiveRecord::RecordNotFound) { object_1.reload }
      DeletePlainObjectWorker.perform_now(object_2, %w[HTestClass123])
      assert_raise(ActiveRecord::RecordNotFound) { object_2.reload }
    end

    def test_perform_destroy_by_association
      objects.each do |object|
        DeletePlainObjectWorker.any_instance.expects(:destroy_by_association).once
        DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123])
      end
    end

    def test_perform_destroy_without_association
      objects.each do |object|
        DeletePlainObjectWorker.any_instance.expects(:destroy_by_association).never
        DeletePlainObjectWorker.perform_now(object, %w[HTestClass123])
      end
    end

    def test_destroy_method_destroy
      object_1 = objects.first
      object_2 = objects.second

      object_1.expects(:destroy).once
      DeletePlainObjectWorker.perform_now(object_1, %w[HTestClass123 HTestClass1123], 'destroy')

      object_1.expects(:destroy!).once
      DeletePlainObjectWorker.perform_now(object_1, [], 'destroy')
    end

    def test_destroy_method_delete
      object_1 = objects.first
      object_2 = objects.second

      object_1.expects(:delete).once
      DeletePlainObjectWorker.perform_now(object_1, %w[HTestClass123 HTestClass1123], 'delete')

      object_1.expects(:delete).once
      DeletePlainObjectWorker.perform_now(object_1, [], 'delete')
    end
  end


  class DeletePlanUpdatePosition < DeletePlainObjectWorkerTest
    test 'destroy plan updates position when the plan is destroyed individually' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.plans.order(position: :asc)
      assert_change of: -> { plans.last.reload.position }, by: -1 do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123])
      end
    end

    test 'destroy plan does not update position when it is destroyed by association for the issuer service with state deleted' do
      service = FactoryBot.create(:simple_service)
      service.update_column(:state, :deleted)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.plans.order(position: :asc)

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123 HTestClass123 HTestClass1123])
      end
    end

    test 'destroy plan does not update position when it is destroyed by association for the issuer service of an account scheduled for deletion' do
      service = FactoryBot.create(:simple_service)
      service.account.update_column(:state, :scheduled_for_deletion)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.plans.order(position: :asc)

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123 HTestClass123 HTestClass1123])
      end
    end

    test 'destroy plan does not update position when it is destroyed by association for the issuer service already deleted' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.plans.order(position: :asc)
      Service.where(id: service.id).delete_all # To don't delete in the same instance :)

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123 HTestClass123 HTestClass1123])
      end
    end

    test 'destroy plan does not update position when it is destroyed by association for the issuer account scheduled for deletion' do
      account = FactoryBot.create(:simple_account)
      FactoryBot.create_list(:simple_account_plan, 2, issuer: account)
      plans = account.account_plans.order(position: :asc)
      account.update_column(:state, :scheduled_for_deletion)

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123 HTestClass123 HTestClass1123])
      end
    end

    test 'destroy plan does not update position when it is destroyed by association for the issuer account already deleted' do
      account = FactoryBot.create(:simple_account)
      FactoryBot.create_list(:simple_account_plan, 2, issuer: account)
      plans = account.account_plans.order(position: :asc)
      Account.where(id: account.id).delete_all # To don't delete in the same instance :)

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(plans.first, %w[HTestClass123 HTestClass123 HTestClass1123])
      end
    end
  end
end
