# frozen_string_literal: true

require 'test_helper'

class DeletePlainObjectWorkerTest < ActiveSupport::TestCase
  class DestroyableObjectsTest < DeletePlainObjectWorkerTest
    def setup
      factory_names = %i[simple_provider service application_plan metric]
      @objects = factory_names.map { |factory_name| FactoryGirl.create(factory_name) }
    end

    attr_reader :objects

    def test_perform_destroy_by_association
      objects.each do |object|
        DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123])
        assert object.destroyed_by_association
        assert_raise(ActiveRecord::RecordNotFound) { object.reload }
      end
    end

    def test_perform_destroy_without_association
      objects.each do |object|
        DeletePlainObjectWorker.perform_now(object, %w[HTestClass123])
        refute object.destroyed_by_association
        assert_raise(ActiveRecord::RecordNotFound) { object.reload }
      end
    end
  end

  class UndestroyableObjectsTest < DeletePlainObjectWorkerTest
    def setup
      @object = FactoryGirl.create(:service)
      @object.stubs(:destroyable?).returns(false)
    end

    attr_reader :object

    def test_perform_destroy_by_association
      DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123])
      System::ErrorReporting.expects(:report_error).never
      assert_nothing_raised(ActiveRecord::RecordNotDestroyed) { DeletePlainObjectWorker.perform_now(object, %w[HTestClass123 HTestClass1123]) }
      refute object.destroyed?
    end

    def test_perform_destroy_without_association
      System::ErrorReporting.expects(:report_error).once.with do |exception, options|
        exception.is_a?(ActiveRecord::RecordNotDestroyed) \
          && (parameters = options[:parameters]) \
          && parameters[:caller_worker_hierarchy] == ['Hierarchy-TestClass-123', "Plain-#{object.class}-#{object.id}"] \
          && parameters[:error_messages] == ['This service cannot be removed']
      end
      assert_nothing_raised(ActiveRecord::RecordNotDestroyed) { DeletePlainObjectWorker.perform_now(object, %w[Hierarchy-TestClass-123]) }
      refute object.destroyed?
    end
  end

  class StaleObjectErrorTest < DeletePlainObjectWorkerTest
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
      service = FactoryGirl.create(:simple_service)
      # There is a restriction on deleting service, at least one should remain
      FactoryGirl.create(:simple_service, account: service.account)

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
        DeletePlainObjectWorker.perform_now(service, ['Hierarchy-Service-ID'])
      end

      # Destroy the proxy in another thread
      f2 = Fiber.new do
        DeletePlainObjectWorker.perform_now(proxy, ['Hierarchy-Service-ID', 'Hierarchy-Proxy-ID'])
      end

      f1.resume
      f2.resume
      f1.resume

      assert_raise(ActiveRecord::RecordNotFound) { proxy.reload }
      assert_raise(ActiveRecord::RecordNotFound) { service.reload }
    end

  end
end
