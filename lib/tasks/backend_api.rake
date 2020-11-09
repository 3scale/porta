# frozen_string_literal: true

namespace :backend_api do
  desc 'Create default metrics for the backend apis that do not have it'
  task :create_default_metrics => :environment do
    BackendApi.order(:id).where.has do
      not_exists Metric.except(:order).where.has { owner_type == BackendApi.name }.where.has { owner_id == BabySqueel[:backend_apis].id }.select(:id)
    end.find_each(&:create_default_metrics)
  end
end
