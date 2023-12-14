# frozen_string_literal: true

class DeleteObjectHierarchyWorker < ApplicationJob

  # No need of ActiveRecord::RecordNotFound because that can only happen in the callbacks and those callbacks don't use this rescue_from but its own rescue
  discard_on ActiveJob::DeserializationError do |job, error|
    Rails.logger.info "#{job.class.name}#perform raised #{error.class} with message #{error.message}"
  end

  queue_as :deletion

  before_perform do |job|
    @object, workers_hierarchy, @background_destroy_method = job.arguments
    id = "Hierarchy-#{object.class.name}-#{object.id}"
    @caller_worker_hierarchy = Array(workers_hierarchy) + [id]
    info "Starting #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  after_perform do |job|
    info "Finished #{job.class}#perform with the hierarchy of workers: #{caller_worker_hierarchy}"
  end

  def perform(_object, _caller_worker_hierarchy = [], _background_destroy_method = 'destroy')
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

  private_constant :ReflectionDestroyer
end
