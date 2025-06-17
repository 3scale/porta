# frozen_string_literal: true

class DeletedObject < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  serialize :metadata, type: Hash

  [Metric, Contract, User, ApplicationKey, ReferrerFilter].each do |scoped_class|
    scoped_class_string = scoped_class.to_s
    scope scoped_class_string.underscore.pluralize.to_sym, -> { where(object_type: scoped_class_string) }
  end

  scope :deleted_owner, -> do
    join_sql = <<-SQL
      INNER JOIN deleted_objects deleted_owner
        ON deleted_objects.owner_type = deleted_owner.object_type
        AND deleted_objects.owner_id = deleted_owner.object_id
    SQL
    joins(join_sql)
  end

  scope :stale, -> do
    where.has do
      ((id.in DeletedObject.unscoped.deleted_owner.select(:id)) | (object_type == Contract.name)) \
      & (created_at <= 1.week.ago)
    end
  end
end
