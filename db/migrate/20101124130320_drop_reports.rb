class DropReports < ActiveRecord::Migration
  def self.up
    drop_table :reports         if table_exists?(:reports)
    drop_table :monthly_reports if table_exists?(:monthly_reports)
    drop_table :daily_reports   if table_exists?(:daily_reports)
    drop_table :hourly_reports  if table_exists?(:hourly_reports)
  end

  def self.down
    # Don't need them
  end
end
