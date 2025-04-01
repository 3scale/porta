# frozen_string_literal: true

class DeleteObjectHierarchyWorker < ApplicationJob

  WORK_TIME_LIMIT_SECONDS = 5
  ASSOCIATION_RE = /Association-(?<klass>[:\w]+)-(?<id>\d+):(?<association>\w+)/

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
  # see https://github.com/veeqo/activejob-uniqueness/blob/v0.2.5/lib/active_job/uniqueness/strategies/until_executed.rb
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
      perform_later(*hierarchy_entries_for(ar_object))
    end

    private

    # @return the hierarchy entries to handle deletion of an object
    def hierarchy_entries_for(ar_object)
      return [] unless ar_object&.persisted? # e.g. when calling Proxy#oidc_configuration a new object can be generated

      if ar_object.respond_to?(:destroyable?, true) && !ar_object.send(:destroyable?)
        raise DoNotRetryError, "Background deleting #{ar_object.class}:#{ar_object.id} which is not destroyable."
      elsif ar_object.is_a?(FeaturesPlan)
        # This is an ugly hack to handle lack of `#id` but we have only FeaturesPlans with a composite primary key.
        # Rails 7.1 supports composite primary keys so we can implement universal handling. See [FeaturesPlan].
        # Now to avoid complications, just sweep it under the rag.
        FeaturesPlan.where(feature_id: ar_object.feature_id, plan_id: ar_object.plan_id).delete_all
        return []
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
    return compatibility(*hierarchy) unless hierarchy.first.is_a?(String)

    started = now
    while hierarchy.present? && now - started < WORK_TIME_LIMIT_SECONDS
      Rails.logger.info "Starting background deletion iteration with: #{hierarchy.join(' ')}"
      handle_one_hierarchy_entry!(hierarchy)
    end

    @remaining_hierarchy = hierarchy
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
  def handle_one_hierarchy_entry!(hierarchy)
    entry = hierarchy.pop
    case entry
    when /Plain-([:\w]+)-(\d+)/
      ar_object = $1.constantize.find($2.to_i)
      match = hierarchy.last&.match(ASSOCIATION_RE)
      if match
        # callbacks logic differs between object destroyed by association, so set it here
        # e.g. for Plans, to prevent acts_as_list to update position of each plan on deletion
        # we want to have here a reflection with a foreign key that is part of the list scope array.
        # see acts_as_list/active_record/acts/scope_method_definer.rb
        # Note that if you hand-craft garbage hierarchy, it may still count as the expected foreign key,
        # e.g. you delete an ApplicationPlan but association is Account:account_plans or
        # e.g. the association is for an unrelated parent object id
        # FYI if there is no such association (e.g. a method name), nil will be returned.
        # Another possible confusion with hand-crafted hierarchies may occur when before
        # a Plain- entry, there is set an unrelated Hierarchy- entry, then incorrect association will be set.
        ar_object.destroyed_by_association = match[:klass].constantize.reflect_on_association(match[:association])
      end
      ar_object.background_deletion_method_call
    when ASSOCIATION_RE
      hierarchy.concat handle_association($1.constantize.find($2.to_i), $3, entry)
    else
      raise ArgumentError, "Invalid entry specification: #{entry}"
    end
    hierarchy
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.warn "#{self.class} skipping object, maybe something else already deleted it: #{exception.message}"
    []
  rescue NameError
    # we would be here in case of a bad crafted hierarchy entry or something else unrecoverable
    # for example NoMethodError on nil class where retrying is pointless but logging the error is needed
    raise DoNotRetryError, "seems like unexpectedly broken delete hierarchy entry: #{entry}"
  end

  # @return a single associated object for deletion or nil if non in the association
  def handle_association(ar_object, association, hierarchy_association_string)
    reflection = ar_object.class.reflect_on_association(association)

    case reflection.macro
    when :has_many
      # here we keep original hierarchy entry if we still find an associated object
      dependent = ar_object.public_send(association).take
      if dependent
        dependent.destroyed_by_association = reflection
        [hierarchy_association_string, *hierarchy_entries_for(dependent)]
      else
        []
      end
    when :has_one
      # maximum of one associated so we never keep the original hierarchy entry
      dependent = ar_object.public_send(association)
      dependent.destroyed_by_association = reflection if dependent
      hierarchy_entries_for dependent
    else
      raise ArgumentError, "Cannot handle association #{ar_object}:#{association} type #{reflection.macro}"
    end
  end

  # previously an example invocation could be with
  # {"_aj_globalid": "gid://system/ProxyRule/1248934"},
  # [
  #   "Hierarchy-Service-2555418046474"
  #   "Hierarchy-Proxy-392685"
  #   "Hierarchy-ProxyRule-1248934"
  # ],
  # "destroy"
  #
  # While it could be called only with the first argument for the root object to be removed.
  def compatibility(object, caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
    # maybe requeue first object from hierarchy would be adequate and uniqueness should deduplicate jobs
    hierarchy_root = Array(caller_worker_hierarchy).first
    return object && self.class.delete_later(object) unless hierarchy_root

    object_class, id = hierarchy_root.match(/Hierarchy-([a-zA-Z0-9_]+)-([\d*]+)/)&.captures

    raise DoNotRetryError, "background deletion cannot handle #{hierarchy_root}" unless object_class && id

    self.class.delete_later object_class.constantize.find(id.to_i)
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.warn "#{self.class} skipping object, maybe something else already deleted it: #{exception.message}"
  end

  delegate :info, to: 'Rails.logger'

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  private_constant :DoNotRetryError, :ASSOCIATION_RE
end
