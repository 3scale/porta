require Rails.root.join('db', 'data_migrations', '20200108171934_update_metric_owners')

class BackfillMetricOwners < ActiveRecord::Migration
  def up
    Metric.reset_column_information
    UpdateMetricOwners.new.up
  end
end
