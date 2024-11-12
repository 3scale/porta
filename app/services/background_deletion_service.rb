# frozen_string_literal: true

class BackgroundDeletionService < ThreeScale::Patterns::Service
  # @param object [ActiveRecord::Base] an object to delete in the background
  def initialize(object)
    self.object = object
  end

  # @return [TrueClass] returns true after a background deletion job was scheduled
  def call
    DeleteObjectHierarchyWorker.perform_later(["Hierarchy-#{object.class}-#{object.id}"])
    true
  end

  private

  attr_accessor :object
end
