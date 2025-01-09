# frozen_string_literal: true

class DeleteObjectHierarchyWorker < ApplicationJob

  WORK_TIME_LIMIT_SECONDS = 5

  class DoNotRetryError < RuntimeError; end

  rescue_from(DoNotRetryError) do |exception|
    # report error and skip retries
    System::ErrorReporting.report_error(exception)
  end

  # we need this only for compatibility to process already enqueued jobs after upgrade
  rescue_from(ActiveJob::DeserializationError) do |exception|
    System::ErrorReporting.report_error(exception)
  end

  queue_as :deletion
  unique :until_executed, lock_ttl: 10.minutes

  # better limit by available  `delete` executors
  # sidekiq_throttle concurrency: { limit: 10 }

  before_perform do |job|
    info "Starting #{job.class}#perform with the hierarchy of workers: #{job.arguments}"
  end

  after_perform do |job|
    info "Finished #{job.class}#perform with the hierarchy of workers: #{job.arguments}"
  end

  # @param hierarchy [Array<String>] something like ["Plain-Service-1234", "Association-Service-1234:plans" ...]
  # @note processes deleting a hierarchy of objects and reschedules itself at current progress after a time limit
  def perform(*hierarchy)
    return compatibility(hierarchy) unless hierarchy.first.is_a?(String)

    started = now
    while now - started < WORK_TIME_LIMIT_SECONDS
      Rails.logger.info "Starting background deletion iteration with: #{hierarchy.join(' ')}"
      hierarchy.concat handle_hierarchy_entry(hierarchy.pop)
    end

    self.class.perform_later(*hierarchy)
  end

  # handles a single hierarchy entry
  # @return [Array<String>] hierarchy for a newly discovered object from association to delete or empty array otherwise
  def handle_hierarchy_entry(entry)
    case entry
    when /Plain-(\w+)-(\d+)/
      ar_object = $1.constantize.find($2.to_i)
      # callbacks logic differs between object destroyed by association, it is standalone if first job arg is itself
      ar_object.destroyed_by_association = DummyDestroyedByAssociationReflection.new(entry) if arguments.first == entry
      ar_object.background_deletion_method_call
      []
    when /Association-(\w+)-(\d+):(\w+)/
      handle_association($1.constantize.find($2.to_i), $3, entry)
    else
      raise ArgumentError, "Invalid entry specification: #{entry}"
    end
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.warn "#{self.class} skipping object, maybe something else already deleted it: #{exception.message}"
  rescue NameError
    raise DoNotRetryError, "seems like unexpectedly broken delete hierarchy entry: #{entry}"
  end

  # @return a single associated object for deletion or nil if non in the association
  def handle_association(ar_object, association, hierarchy_association_string)
    reflection = ar_object.class.reflect_on_association(association)
    case reflection.macro
    when :has_many
      # here we keep original hierarchy entry if we still find an associated object
      dependent = ar_object.public_send(association).public_send(:background_deletion_scope).take
      dependent ? [hierarchy_association_string, *hierarchy_entries_for(dependent)] : []
    when :has_one
      # maximum of one associated so we never keep the original hierarchy entry
      hierarchy_entries_for ar_object.public_send(association)
    else
      raise ArgumentError, "Cannot handle association #{ar_object}:#{association} type #{reflection.macro}"
    end
  end

  # @return the hierarchy entries to handle deletion of an object
  def hierarchy_entries_for(ar_object)
    if ar_object.is_a?(Account) && !ar_object.should_be_deleted?
      raise DoNotRetryError, "background deleting account #{ar_object.id} which is not scheduled for deletion"
    end

    ar_object_str = "#{ar_object.class}-#{ar_object.id}"

    [
      "Plain-#{ar_object_str}",
      *ar_object.background_deletion.map { "Association-#{ar_object_str}:#{_1}" },
    ]
  end

  def compatibility(_object, caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
    # maybe requeue first object from hierarchy would be adequate and uniqueness should deduplicate jobs
    hierarchy_root = Array(caller_worker_hierarchy).first
    return unless hierarchy_root

    object_class, id = hierarchy_root.match(/Hierarchy-([a-zA-Z0-9_]+)-([\d*]+)/).captures

    raise DoNotRetryError, "background deletion cannot handle #{hierarchy_root}" unless object_class && id

    root_object = object_class.constantize.find(id.to_i)
    self.class.perform_later hierarchy_entries_for(root_object)
  end

  def associations_strings(ar_object, *associations)
    associations = ar_object.class.background_deletion if associations.blank?
    associations.map do |association|
      "Association-#{ar_object.class}-#{ar_object.id}:#{association}"
    end
  end

  # we can just use job.arguments.first but for compatibility mode we want it not to lock
  def lock_key
    first_argument = job.arguments.first
    first_argument.is_a?(String) ? first_argument : Random.uuid
  end

  private

  delegate :info, to: 'Rails.logger'

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  class DummyDestroyedByAssociationReflection
    def initialize(foreign_key)
      @foreign_key = foreign_key
    end
    attr_reader :foreign_key
  end

  private_constant :DoNotRetryError, :DummyDestroyedByAssociationReflection
end
