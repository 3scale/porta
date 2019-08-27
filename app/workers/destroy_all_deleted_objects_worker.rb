class DestroyAllDeletedObjectsWorker
  include Sidekiq::Worker

  def perform(class_name, method = :deleted)
    class_name.constantize.public_send(method).find_each(&DeleteObjectHierarchyWorker.method(:perform_later))
  end
end
