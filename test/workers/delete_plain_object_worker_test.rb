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
end
