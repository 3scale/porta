# frozen_string_literal: true

require 'test_helper'

module Tasks
  class DeletedObjectsTest < ActiveSupport::TestCase
    test 'destroy_deleted_objects_with_owner_service_destroyed' do

      # Metric Object destroyed with Service owner persisted
      service = FactoryBot.create(:simple_service)
      metric = FactoryBot.create(:metric, owner: service)
      DeletedObject.create!(object: metric, owner: service)
      metric.delete

      # Metric Object destroyed with Service owner destroyed (without its own DeletedObject)
      service = FactoryBot.create(:simple_service)
      metric = FactoryBot.create(:metric, owner: service)
      object_with_service_owner_destroyed = DeletedObject.create!(object: metric, owner: service)
      metric.delete
      service.delete

      # Service Object destroyed
      service = FactoryBot.create(:simple_service)
      DeletedObject.create!(object: service, owner: service.account)
      service.delete


      assert_difference(DeletedObject.method(:count), -1) do
        execute_rake_task 'deleted_objects.rake', 'deleted_objects:destroy_deleted_objects_with_owner_service_destroyed'
      end
      assert_raise(ActiveRecord::RecordNotFound) { object_with_service_owner_destroyed.reload }
    end

    test 'destroy_objects_with_service_owner_or_service_objects' do
      service = FactoryBot.create(:simple_service)
      metric = FactoryBot.create(:metric, owner: service)
      delete_object_with_service_owner = DeletedObject.create!(object: metric, owner: service)

      service = FactoryBot.create(:simple_service)
      account = service.account
      delete_object_with_service_object = DeletedObject.create(object: service, owner: account)


      assert_difference(DeletedObject.method(:count), -2) do
        execute_rake_task 'deleted_objects.rake', 'deleted_objects:destroy_objects_with_service_owner_or_service_objects'
      end
      assert_raise(ActiveRecord::RecordNotFound) { delete_object_with_service_owner.reload }
      assert_raise(ActiveRecord::RecordNotFound) { delete_object_with_service_object.reload }
    end
  end
end
