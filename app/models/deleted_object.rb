# frozen_string_literal: true

class DeletedObject < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  [Metric, Contract].each do |scoped_class|
    scope scoped_class.to_s.underscore.pluralize.to_sym, -> { where(object_type: scoped_class) }
  end

  scope :missing_owner, lambda {
    associations = distinct(:owner_type).pluck(:owner_type).map(&:constantize).map do |association|
      -> { joining { owner.of(association).outer }.where("#{association.table_name}.id IS NULL") }
    end
    associations.inject(all) { |chain, association| chain.merge!(association) }
  }

  # TODO: This is really bad :) It is just a 1st step :)
  scope :missing_owner_event, lambda {
    associations = distinct(:owner_type).pluck(:owner_type).map(&:constantize).map do |association|
      -> {
        joins("LEFT OUTER JOIN event_store_events AS #{association.table_name}_events ON #{association.table_name}_events.event_type = '#{h = Hash.new(nil).merge(Service.table_name => Services::ServiceDeletedEvent); h[association.table_name]}' AND #{association.table_name}_events.data LIKE CONCAT('%\nservice_id: ',  owner_id, '\n%')")
          .where("#{association.table_name}_events.event_id IS NULL")
       }
    end
    associations.inject(all) { |chain, association| chain.merge!(association) }
  }

  scope :stale, -> { missing_owner.missing_owner_event }
end
