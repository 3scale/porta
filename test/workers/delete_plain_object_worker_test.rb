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



end
