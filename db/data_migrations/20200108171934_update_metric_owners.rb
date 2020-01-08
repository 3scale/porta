# frozen_string_literal: true

require 'progress_counter'

class UpdateMetricOwners < ActiveRecord::DataMigration
  def up
    progress = ProgressCounter.new(Metric.count)
    Metric.find_each do |metric|
      metric.update_columns(owner_id: metric.service_id, owner_type: 'Service') unless metric.owner_type?
      progress.call
    end
  end
end
