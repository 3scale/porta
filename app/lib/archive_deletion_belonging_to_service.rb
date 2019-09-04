# frozen_string_literal: true

module ArchiveDeletionBelongingToService
  extend ActiveSupport::Concern
  included do
    after_destroy :archive_as_deleted
  end

  private

  def archive_as_deleted
    ::DeletedObject.create!(object: self, owner: service)
  end
end
