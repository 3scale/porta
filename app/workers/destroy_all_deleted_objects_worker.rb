# frozen_string_literal: true

class DestroyAllDeletedObjectsWorker < ApplicationJob
  def perform(class_name)
    class_name.constantize.deleted.find_each(&DeleteObjectHierarchyWorker.method(:perform_later))
  end
end
