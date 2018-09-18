class AddNotNullCreatedAtToMetrics < ActiveRecord::Migration
  def change
    Metric.where(created_at: nil).delete_all
    change_column_null(:metrics, :created_at, false)
  end
end
