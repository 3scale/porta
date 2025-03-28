# frozen_string_literal: true

class DeleteAllStaleObjectsWorker < ApplicationJob

  queue_as :deletion

  def perform(*classes_names)
    classes_names.each do |class_name|
      delete_all_stale_in_batches class_name.constantize
    end
  end

  private

  def delete_all_stale_in_batches(model, batch_size: 500)
    sleep 1 until model.stale.limit(batch_size).delete_all < batch_size
  end

end
