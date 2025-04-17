# frozen_string_literal: true

class DeleteAllStaleObjectsWorker < ApplicationJob

  queue_as :deletion

  def perform(*classes_names)
    classes_names.each do |class_name|
      delete_all_stale class_name.constantize
    end
  end

  private

  def delete_all_stale(model)
    model.stale.delete_all
  end

end
