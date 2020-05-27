# frozen_string_literal: true

namespace :deleted_objects do
  desc 'Destroy all the DeletedObjects whose owner is a Service that does not exist in the services table anymore'
  task :destroy_deleted_objects_with_owner_service_destroyed => :environment do
    deleted_objects_from_deleted_service_owners = DeletedObject.where.has { owner_type == Service.name }.where.has do
      not_exists(Service.where.has { id == BabySqueel[:deleted_objects].owner_id })
    end
    deleted_objects_from_deleted_service_owners.find_in_batches(batch_size: 300) do |records|
      DeletedObject.where(id: records.map(&:id)).destroy_all
      sleep(0.5) unless Rails.env.test?
    end
  end

  desc 'Destroy all the objects whose owner is a Service OR whose object_type is a Service'
  task :destroy_objects_with_service_owner_or_service_objects => :environment do
    objects_with_service_owner_or_service_objects= DeletedObject.where.has do
      ((owner_type == Service.name) | (object_type == Service.name))
    end
    objects_with_service_owner_or_service_objects.find_in_batches(batch_size: 500) do |records|
      DeletedObject.where(id: records.map(&:id)).destroy_all
      sleep(0.5) unless Rails.env.test?
    end
  end
end
