# frozen_string_literal: true

class DeletedObject < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  [Metric, Contract].each do |scoped_class|
    scope scoped_class.to_s.underscore.pluralize.to_sym, -> { where(object_type: scoped_class) }
  end

  # Using this in scopes is dangerous as it's not thread-safe https://github.com/3scale/porta/pull/941/files#r299878052
  def self.owner_types
    unscoped.distinct(:owner_type).pluck(:owner_type)
  end

  scope :missing_owner, lambda {
    all.where.has { DeletedObject.owner_types.map(&:constantize).map { |association| not_exists(association.where("#{association.table_name}.id = deleted_objects.owner_id")).to_sql }.join(' AND ') }
  }

  OWNER_TYPES = {
    'Service': { event_class: Services::ServiceDeletedEvent, event_selector: -> { data =~ sift(:concat, sql("'%\nservice_id: '"), BabySqueel[:deleted_objects].owner_id, sql("'\n%'")) } }, # cannot use BabySqueel::DSL#quoted with the escape character ('\'). It's actually ActiveRecord::ConnectionAdapters::Quoting's fault
    'Account': { event_class: Accounts::AccountDeletedEvent, event_selector: -> { data =~ sift(:concat, sql("'%\naccount_id: '"), BabySqueel[:deleted_objects].owner_id, sql("'\n%'")) } }
  }.with_indifferent_access.freeze

  private_constant :OWNER_TYPES

  scope :missing_owner_event, lambda {
    all.where.has do
      DeletedObject.owner_types.map do |klass|
        if OWNER_TYPES.key?(klass)
          event_class = [*OWNER_TYPES.dig(klass, :event_class)]
          event_selector = OWNER_TYPES.dig(klass, :event_selector)
          not_exists(EventStore::EventRecordBase.where.has { event_type.in(event_class) & instance_exec(&event_selector) }).to_sql
        else
          (owner_type != klass).to_sql
        end
      end.join(' AND ')
    end
  }

  scope :stale, -> { missing_owner.missing_owner_event }
end
