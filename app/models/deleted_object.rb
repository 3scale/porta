# frozen_string_literal: true

class DeletedObject < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  [Metric, Contract].each do |scoped_class|
    scope scoped_class.to_s.underscore.pluralize.to_sym, -> { where(object_type: scoped_class) }
  end

  scope(:deleted_owner, lambda do
    join_sql = <<-SQL
      INNER JOIN deleted_objects AS deleted_owner
        ON deleted_objects.owner_type = deleted_owner.object_type
        AND deleted_objects.owner_id = deleted_owner.object_id
    SQL
    joins(join_sql)
  end)

  scope(:stale, lambda do
    where.has { ((id.in DeletedObject.deleted_owner.select(:id)) | (object_type == Service.name)) & (created_at <= 1.week.ago) }
  end)
end
