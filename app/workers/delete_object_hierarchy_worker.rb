# frozen_string_literal: true

# TODO: Rails 5 --> class DeleteObjectHierarchyWorker < ApplicationJob
class DeleteObjectHierarchyWorker < ActiveJob::Base

  # TODO: Rails 5 --> discard_on ActiveJob::DeserializationError
  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "DeleteObjectHierarchyWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  queue_as :default

  before_perform do |job|
    @object, workers_hierarchy = job.arguments
    id = "Hierarchy-#{object.class.name}-#{object.id}"
    @caller_worker_hierarchy = Array(workers_hierarchy) + [id]
    info "Starting #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  after_perform do |job|
    info "Finished #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  def perform(_object, _caller_worker_hierarchy = [])
    build_batch
  end

  def on_success(_status, options)
    workers_hierarchy = options['caller_worker_hierarchy']
    info "Starting DeleteObjectHierarchyWorker#on_success with the hierarchy of workers: #{workers_hierarchy}"
    object = GlobalID::Locator.locate options['object_global_id']
    DeletePlainObjectWorker.perform_later(object, workers_hierarchy)
    info "Finished DeleteObjectHierarchyWorker#on_success with the hierarchy of workers: #{workers_hierarchy}"
  rescue ActiveRecord::RecordNotFound => exception
    info "DeleteObjectHierarchyWorker#on_success raised #{exception.class} with message #{exception.message}"
  end

  def on_complete(_status, options)
    global_id = options['object_global_id']
    workers_hierarchy = options['caller_worker_hierarchy']
    info "Starting DeleteObjectHierarchyWorker#on_complete with the hierarchy of workers: #{workers_hierarchy}"
    object = GlobalID::Locator.locate(global_id)
    DeletePlainObjectWorker.perform_later(object, workers_hierarchy)
    info "Finished DeleteObjectHierarchyWorker#on_complete with the hierarchy of workers: #{workers_hierarchy}"
  rescue ActiveRecord::RecordNotFound
    info "DeleteObjectHierarchyWorker#on_complete #{global_id} has been already destroyed"
  end

  protected

  delegate :info, to: 'Rails.logger'

  attr_reader :object, :caller_worker_hierarchy

  def build_batch
    batch = Sidekiq::Batch.new
    batch.description = batch_description
    batch.on(:complete, self.class, callback_options)
    batch_success_callback(batch) { batch.jobs { delete_associations(object) } }
    batch
  end

  def batch_description
    "Deleting #{object.class.name} [##{object.id}]"
  end

  def batch_success_callback(batch)
    options = callback_options
    batch.on(:success, self.class, options)
    yield
    bid = batch.bid
    on_success(bid, options) if Sidekiq::Batch::Status.new(bid).total.zero?
  end

  def delete_associations(object)
    associations_to_destroy_for(object).each do |reflection|
      worker = association_delete_worker(reflection)
      delete_objects_of_association(object, reflection.name, worker)
    end
  end

  private

  def callback_options
    { 'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy }
  end

  def delete_objects_of_association(main_object, association_name, worker)
    return unless (associated_objects = main_object.public_send(association_name))
    if associated_objects.respond_to?(:each)
      associated_objects.each { |associated_object| delete_association_perform_later(worker, associated_object) }
    else
      delete_association_perform_later(worker, associated_objects)
    end
  end

  def associations_to_destroy_for(record)
    record.class.reflect_on_all_associations.select { |reflection| reflection.options[:dependent] == :destroy }
  end

  def delete_association_perform_later(worker, object)
    worker.perform_later(object, caller_worker_hierarchy)
  end

  def association_delete_worker(reflection)
    delete_hierarchy_workers = Hash.new(DeleteObjectHierarchyWorker).merge('Account' => DeleteAccountHierarchyWorker)
    delete_hierarchy_workers[reflection.options[:class_name]]
  end

end
