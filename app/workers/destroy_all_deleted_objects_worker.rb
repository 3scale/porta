class DestroyAllDeletedObjectsWorker
  include Sidekiq::Worker

  def perform(class_name)
    class_name.constantize.deleted.find_each(&DeleteObjectHierarchyWorker.method(:perform_later))
  end
end
