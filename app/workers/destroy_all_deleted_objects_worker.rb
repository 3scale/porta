class DestroyAllDeletedObjectsWorker
  include Sidekiq::Worker

  def perform(class_name)
    class_name.constantize.deleted.destroy_all
  end
end
