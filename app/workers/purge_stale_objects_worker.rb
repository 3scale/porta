# frozen_string_literal: true

class PurgeStaleObjectsWorker < ApplicationJob

  def perform(*classes_names)
    classes_names.each do |class_name|
      class_name.constantize.stale.find_each(&DeleteObjectHierarchyWorker.method(:delete_later))
    end
  end

end
