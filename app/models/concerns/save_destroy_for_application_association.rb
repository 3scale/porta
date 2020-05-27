# frozen_string_literal: true

module SaveDestroyForApplicationAssociation
  extend ActiveSupport::Concern
  included do
    after_destroy :archive_as_deleted, if: :destroyed_by_association
  end

  private

  def archive_as_deleted
    ::DeletedObject.create!(object: self, owner: application, metadata: {value: value})
  end
end
