# frozen_string_literal: true

class BackendUpdateApplicationPlanJob
  include Sidekiq::IterableJob
  include Sidekiq::Throttled::Job

  sidekiq_options queue: :backend_sync

  sidekiq_throttle concurrency: {
    limit: 1,
    key_suffix: ->(plan_id) { "plan:#{plan_id}" },
    ttl: 1.hour.to_i
  }

  def build_enumerator(plan_id, cursor:)
    plan = ApplicationPlan.find_by(id: plan_id)
    return unless plan

    active_record_batches_enumerator(plan.cinstances, cursor: cursor, batch_size: 10_000)
  end

  # :reek:UtilityFunction :reek:TooManyStatements
  def each_iteration(batch, plan_id)
    plan = ApplicationPlan.find_by(id: plan_id)
    return unless plan

    save_backend_applications(batch, plan)
  end

  private

  def save_backend_applications(batch, plan)
    service = plan.service
    applications = batch.map { |app| app.backend_application_attributes(service, plan) }
    ThreeScale::Core::Application.save_batch(service.backend_id, applications)
  rescue StandardError => exception
    Rails.logger.error("Failed to sync application plan #{plan.name} to backend: #{exception.message}")
  end
end
