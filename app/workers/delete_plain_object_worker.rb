# frozen_string_literal: true

# TODO: Rails 5 --> class DeletePlainObjectWorker < ApplicationJob
class DeletePlainObjectWorker < ActiveJob::Base

  # TODO: Rails 5 --> discard_on ActiveJob::DeserializationError, ActiveRecord::RecordNotFound
  rescue_from(ActiveJob::DeserializationError, ActiveRecord::RecordNotFound) do |exception|
    Rails.logger.info "DeletePlainObjectWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  rescue_from(ActiveRecord::RecordNotDestroyed) do |exception|
    if object.class.exists?(object.id)
      # We don't want to indefinitely try again to delete an object that for any reason can not be destroyed, so we just log it instead
      System::ErrorReporting.report_error(exception, parameters: { caller_worker_hierarchy: caller_worker_hierarchy,
                                                                   error_messages: exception.record.errors.full_messages })
    end
  end

  rescue_from(ActiveRecord::StaleObjectError) do |_exception|
    Rails.logger.info "DeletePlainObjectWorker#perform raised #{exception.class} with message #{exception.message} for the hierarchy #{caller_worker_hierarchy}"
    retry_job if object.class.exists?(object.id)
  end

  queue_as :default

  before_perform do |job|
    @object, workers_hierarchy = job.arguments
    @id = "Plain-#{object.class.name}-#{object.id}"
    @caller_worker_hierarchy = Array(workers_hierarchy) + [@id]
    info "Starting #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  after_perform do |job|
    info "Finished #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  def perform(_object, _caller_worker_hierarchy = [])
    should_destroy_by_association? ? destroy_by_association : object.destroy!
  end

  private

  delegate :info, to: 'Rails.logger'

  attr_reader :caller_worker_hierarchy, :id, :object

  def should_destroy_by_association?
    # If there is 1 only it means caller_worker_hierarchy argument to perform was an empty array and that 1 element is this DeletePlainObjectWorker instance itself
    # If there are 2 it means that there is a DeleteObjectHierarchyWorker object (position 0 of the Array) that called to this DeletePlainObjectWorker instance itself (position 1 of the Array)
    # More than 2 it means there is a chain of DeleteObjectHierarchyWorker objects before reaching this DeletePlainObjectWorker and that chain is the 'delete by association'.
    # For example this could be a Service object with ID 3 of a Provider object with ID 2 and the chain at this point would look like [Hierarchy-Provider-2, Hierarchy-Service-3, Plain-Service-3].
    # This 'code' is for logging purposes only and Hierarchy means DeleteObjectHierarchyWorker and Plain means DeletePlainObjectWorker, then the model and the ID.
    # You can see more about this argument and what should happen here in DeletePlainObjectWorkerTest
    caller_worker_hierarchy.length > 2
  end

  def destroy_by_association
    object.destroyed_by_association = DummyDestroyedByAssociationReflection.new(id)
    object.destroy
  end

  class DummyDestroyedByAssociationReflection
    def initialize(foreign_key)
      @foreign_key = foreign_key
    end
    attr_reader :foreign_key
  end
  private_constant :DummyDestroyedByAssociationReflection

end
