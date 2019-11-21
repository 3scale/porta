require 'progress_counter'

class BackfillMetricOwners < ActiveRecord::Migration
  def up
    Metric.reset_column_information
    Rake::Task['services:update_metric_owners'].invoke
  end
end
