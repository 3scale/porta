# frozen_string_literal: true

class DeleteObjectHierarchyWorker < ApplicationJob

  # attr_reader :hierarchy

  rescue_from(DoNotRetryError) do |exception|
    # report error and skip retries
    System::ErrorReporting.report_error(exception)
  end

  # we need this only for compatibility to process already enqueued jobs after upgrade
  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "DeleteObjectHierarchyWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  queue_as :deletion
  unique :until_executed, lock_ttl: 10.minutes

  before_perform do |job|
    # @object, workers_hierarchy, @background_destroy_method = job.arguments
    # id = "Hierarchy-#{object.class.name}-#{object.id}"
    # @caller_worker_hierarchy = Array(workers_hierarchy) + [id]
    info "Starting #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  after_perform do |job|
    info "Finished #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  # @param hierarchy [Array<String>] something like ["Plain-Service-1234", "Association-Service-1234:plans" ...]
  # @note processes the last entry for deletion from hierarchy and re-schedules itself with updated hierarchy
  def perform(*hierarchy)
    return compatibility(hierarchy) unless hierarchy.first.is_a?(String)

    hierarchy.concat handle_hierarchy_entry(hierarchy.pop)
    self.class.perform_later(*hierarchy)
  end

  # handles a single hierarchy entry
  # @return [Array<String>] hierarchy for a newly discovered object from association to delete or empty array otherwise
  def handle_hierarchy_entry(entry)
    case entry
    when /Plain-(\w+)-(\d+)/
      delete_plain($1.constantize.find($2.to_i))
      []
    when /Association-(\w+)-(\d+):(\w+)/
      handle_one_associated($1.constantize.find($2.to_i), $3, entry)
    else
      raise ArgumentError, "Invalid entry specification: #{entry}"
    end
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.warn "#{self.class} skipping object, maybe something else already deleted it: #{exception.message}"
  rescue NameError
    raise DoNotRetryError, "seems like unexpectedly broken delete hierarchy entry: #{entry}"
  end

  # @return a single associated object for deletion or nil if non in the association
  def handle_one_associated(ar_object, association, original_entry)
    reflection = ar_object.class.reflect_on_association(association)
    case reflection.macro
    when :has_many
      TODO
    when :has_one
      TODO
    else
      raise ArgumentError, "Cannot handle association #{ar_object}:#{association} type #{reflection.macro}"
    end
  end

  # @return the hierarchy entries to handle deletion of an object
  def entries_for(ar_object)
    TODO
  end

  def compatibility(_object, _caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
    # maybe requeue first object from hierarchy would be adequate and uniqueness should deduplicate jobs
    TODO
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

  ############# ORIG ################
  def x_perform(_object, _caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
    build_batch
  end

  def on_success(_, options)
    on_finish('on_success', options)
  end

  def on_complete(_, options)
    on_finish('on_complete', options)
  end

  def on_finish(method_name, options)
    workers_hierarchy = options['caller_worker_hierarchy']
    info "Starting DeleteObjectHierarchyWorker##{method_name} with the hierarchy of workers: #{workers_hierarchy}"
    object = GlobalID::Locator.locate(options['object_global_id'])
    background_destroy_method = @background_destroy_method.presence || 'destroy'
    DeletePlainObjectWorker.perform_later(object, workers_hierarchy, background_destroy_method)
    info "Finished DeleteObjectHierarchyWorker##{method_name} with the hierarchy of workers: #{workers_hierarchy}"
  rescue ActiveRecord::RecordNotFound => exception
    info "DeleteObjectHierarchyWorker##{method_name} raised #{exception.class} with message #{exception.message}"
  end

  protected

  delegate :info, to: 'Rails.logger'

  attr_reader :object, :caller_worker_hierarchy

  def build_batch
    batch = Sidekiq::Batch.new
    batch.description = batch_description
    batch_callbacks(batch) { batch.jobs { destroy_and_delete_associations } }
    batch
  end

  def batch_description
    "Deleting #{object.class.name} [##{object.id}]"
  end

  def batch_callbacks(batch)
    %i[success complete].each { |name| batch.on(name, self.class, callback_options) }
    yield
    bid = batch.bid

    if Sidekiq::Batch::Status.new(bid).total.zero?
      on_complete(bid, callback_options)
    else
      info("DeleteObjectHierarchyWorker#batch_success_callback retry job with the hierarchy of workers: #{caller_worker_hierarchy}")
      retry_job wait: 5.minutes
    end
  end

  def destroy_and_delete_associations
    Array(object.background_deletion).each do |association_config|
      reflection = BackgroundDeletion::Reflection.new(association_config)
      next unless destroyable_association?(reflection.name)

      ReflectionDestroyer.new(object, reflection, caller_worker_hierarchy).destroy_later
    end
  end

  def destroyable_association?(_association)
    true
  end

  private

  def called_from_provider_hierarchy?
    return unless (tenant_id = object.tenant_id)
    caller_worker_hierarchy.include?("Hierarchy-Account-#{tenant_id}")
  end

  def callback_options
    { 'object_global_id' => object.to_global_id, 'caller_worker_hierarchy' => caller_worker_hierarchy }
  end

  class ReflectionDestroyer

    def initialize(main_object, reflection, caller_worker_hierarchy)
      @main_object = main_object
      @reflection = reflection
      @caller_worker_hierarchy = caller_worker_hierarchy
    end

    def destroy_later
      reflection.many? ? destroy_has_many_association : destroy_has_one_association
    end

    attr_reader :main_object, :reflection, :caller_worker_hierarchy

    private

    def destroy_has_many_association
      main_object.public_send("#{reflection.name.to_s.singularize}_ids").each do |associated_object_id|
        associated_object = reflection.class_name.constantize.new
        associated_object.id = associated_object_id
        delete_associated_object_later(associated_object)
      end
    rescue ActiveRecord::UnknownPrimaryKey => exception
      Rails.logger.info "DeleteObjectHierarchyWorker#perform raised #{exception.class} with message #{exception.message}"
    end

    def destroy_has_one_association
      associated_object = main_object.public_send(reflection.name)
      delete_associated_object_later(associated_object)
    end

    def delete_associated_object_later(associated_object)
      association_delete_worker.perform_later(associated_object, caller_worker_hierarchy, reflection.background_destroy_method) if associated_object.try(:id)
    end

    def association_delete_worker
      case reflection.class_name
      when Account.name
        DeleteAccountHierarchyWorker
      when PaymentGatewaySetting.name
        DeletePaymentSettingHierarchyWorker
      else
        DeleteObjectHierarchyWorker
      end
    end
  end

  class DoNotRetryError < RuntimeError; end

  private_constant :ReflectionDestroyer, :DoNotRetryError
end
