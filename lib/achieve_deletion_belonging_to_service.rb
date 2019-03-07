# frozen_string_literal: true

module AchieveDeletionBelongingToService
  extend ActiveSupport::Concern
  included do
    after_destroy :achieve_as_deleted
  end

  private

  def achieve_as_deleted
    ::DeletedObject.create!(object: self, owner: service)
  end
end
