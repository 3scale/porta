# frozen_string_literal: true

class DeletedObject < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  [Metric, Contract].each do |scoped_class|
    scope scoped_class.to_s.underscore.pluralize.to_sym, -> { where(object_type: scoped_class) }
  end

  scope :service_owner, -> { where.has { owner_type == Service } }
  scope :service_owner_not_exists, -> { service_owner.joining { owner.of(Service).outer }.where('services.id IS NULL') }
  scope :service_owner_event_not_exists, lambda {
    service_owner.where.has { not_exists EventStore::Services::ServiceDeletedEvent.by_service_id('deleted_objects.owner_id') }
  }
  scope :stale, -> { service_owner_not_exists.service_owner_event_not_exists }
end
