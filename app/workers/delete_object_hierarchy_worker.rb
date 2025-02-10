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

  # until_executed seems to rely on #after_perform which is skipped on failure so not sure whether retries will work.
  # additionally if we want to reschedule ourselves in #after_perform, it is not nice to rely on flaky order
  # see https://github.com/3scale/activejob-uniqueness/blob/main/lib/active_job/uniqueness/strategies/until_executed.rb
  unique :until_and_while_executing, lock_ttl: 6.hours

  # better limit by available  `delete` executors
  # sidekiq_throttle concurrency: { limit: 10 }

  before_perform do |job|
    info "Starting #{job.class}#perform with the hierarchy of workers: #{job.arguments}"
  end

  after_perform do |job|
    if @remaining_hierarchy.present?
      self.class.perform_later(*@remaining_hierarchy)
      msg = " iteration of"
    end
    info "Finished#{msg} #{job.class}#perform with the hierarchy of workers: #{job.arguments}"
  end

  class << self
    # convenience method to schedule deleting an active record object
    def delete_later(ar_object)
      perform_later *hierarchy_entries_for(ar_object)
    end

    private

    # @return the hierarchy entries to handle deletion of an object
    def hierarchy_entries_for(ar_object)
      return [] unless ar_object&.persisted? # e.g. when calling Proxy#oidc_configuration a new object can be generated

      if ar_object.is_a?(Account) && !ar_object.should_be_deleted?
        raise DoNotRetryError, "background deleting account #{ar_object.id} which is not scheduled for deletion"
      end

      ar_object_str = "#{ar_object.class}-#{ar_object.id}"

      [
        "Plain-#{ar_object_str}",
        *ar_object.background_deletion.map { "Association-#{ar_object_str}:#{_1}" },
      ]
    end
  end

  # @param hierarchy [Array<String>] something like ["Plain-Service-1234", "Association-Service-1234:plans" ...]
  # @note processes deleting a hierarchy of objects and reschedules itself at current progress after a time limit
  def perform(*hierarchy)
    return compatibility(hierarchy) unless hierarchy.first.is_a?(String)

    started = now
    while hierarchy.present? && now - started < WORK_TIME_LIMIT_SECONDS
      Rails.logger.info "Starting background deletion iteration with: #{hierarchy.join(' ')}"
      hierarchy.concat handle_hierarchy_entry(hierarchy.pop)
    end

    @remaining_hierarchy = hierarchy
    # can be like this instead of in `after_perform`, the benefit is that we don't use undocumented order of callbacks
    # return unless hierarchy.present?
    #
    # # depending on
    # unlock(resource: lock_key)
    # self.class.perform_later(*hierarchy)
  end

  # we can just use job.arguments.first but for compatibility mode we want it not to lock
  def lock_key
    first_argument = arguments.first
    first_argument.is_a?(String) ? first_argument : Random.uuid
  end

  private

  def hierarchy_entries_for(...)
    self.class.send(:hierarchy_entries_for, ...)
  end

  # handles a single hierarchy entry
  # @return [Array<String>] hierarchy for a newly discovered object from association to delete or empty array otherwise
  def handle_hierarchy_entry(entry)
    case entry
    when /Plain-([:\w]+)-(\d+)/
      ar_object = $1.constantize.find($2.to_i)
      # callbacks logic differs between object destroyed by association, it is standalone if first job arg is itself
      ar_object.destroyed_by_association = DummyDestroyedByAssociationReflection.new(arguments.first) if arguments.first != entry
      ar_object.background_deletion_method_call
      []
    when /Association-([:\w]+)-(\d+):(\w+)/
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

  def compatibility(object, caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
    # maybe requeue first object from hierarchy would be adequate and uniqueness should deduplicate jobs
    hierarchy_root = Array(caller_worker_hierarchy).first
    return object && self.class.delete_later(object) unless hierarchy_root

    object_class, id = hierarchy_root.match(/Hierarchy-([a-zA-Z0-9_]+)-([\d*]+)/).captures

    raise DoNotRetryError, "background deletion cannot handle #{hierarchy_root}" unless object_class && id

    self.class.delete_later object_class.constantize.find(id.to_i)
  end

  def associations_strings(ar_object, *associations)
    associations = ar_object.class.background_deletion if associations.blank?
    associations.map do |association|
      "Association-#{ar_object.class}-#{ar_object.id}:#{association}"
    end
  end

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
