# frozen_string_literal: true

require 'test_helper'

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

  class UndestroyableObjectsTest < DeletePlainObjectWorkerTest
    def setup
      @object = FactoryBot.create(:service)
      @object.stubs(:destroyable?).returns(false)
    end

    attr_reader :object

    def test_perform_destroy_by_association
      DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123])
      System::ErrorReporting.expects(:report_error).never
      # shouldn't raise anything
      DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123])
      refute object.destroyed?
    end

    def test_perform_destroy_without_association
      System::ErrorReporting.expects(:report_error).once.with do |exception, options|
        exception.is_a?(ActiveRecord::RecordNotDestroyed) \
          && (parameters = options[:parameters]) \
          && parameters[:caller_worker_hierarchy] == ['Hierarchy-TestClass-123', "Plain-#{object.class}-#{object.id}"] \
          && parameters[:error_messages] == ['This product cannot be removed']
      end
      # shouldn't raise anything
      DeletePlainObjectWorker.perform_now(object, %w[Hierarchy-TestClass-123])
      refute object.destroyed?
    end
  end

  class StaleObjectErrorTest < DeletePlainObjectWorkerTest
    include ActiveJob::TestHelper

    module LoadTargetWithFiber
      # Overriding the `delete` method of HasOneAssociation https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/associations/has_one_association.rb#L53-L64
      # When entering this method, override the `load_target` method so we can hand over the execution to the main thread
      def delete
        def load_target
          super.tap { Fiber.yield }
        end

        super
      end
    end

    def test_race_condition
      service = FactoryBot.create(:simple_service)
      # There is a restriction on deleting service, at least one should remain
      FactoryBot.create(:simple_service, account: service.account)

      proxy = Proxy.find service.proxy.id
      service = Service.find service.id

      # Make sure that there is no more than one because it is a `has_one` association
      assert_equal 1, Proxy.where(service_id: service.id).count

      proxy_association = service.association :proxy

      # Hook into the Eigenclass
      class << proxy_association
        prepend LoadTargetWithFiber
      end

      # Execute deletion of service but suspend the execution of deleting the proxy by `:dependent => :destroy`
      f1 = Fiber.new do
        Sidekiq::Testing.inline! { DeletePlainObjectWorker.perform_now(service, ['Hierarchy-Service-ID']) }
      end

      # Destroy the proxy in another thread
      f2 = Fiber.new do
        Sidekiq::Testing.inline! { DeletePlainObjectWorker.perform_now(proxy, ['Hierarchy-Service-ID', 'Hierarchy-Proxy-ID']) }
      end

      perform_enqueued_jobs only: DeletePlainObjectWorker do
        f1.resume
        f2.resume
        f1.resume
      end

      assert_raise(ActiveRecord::RecordNotFound) { proxy.reload }
      assert_raise(ActiveRecord::RecordNotFound) { service.reload }
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
