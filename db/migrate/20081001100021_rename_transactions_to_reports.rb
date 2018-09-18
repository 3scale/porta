class RenameTransactionsToReports < ActiveRecord::Migration
  def self.up
    rename_table 'transactions', 'reports'
    rename_table 'hourly_transactions', 'hourly_reports'
    rename_table 'daily_transactions', 'daily_reports'
    rename_table 'monthly_transactions', 'monthly_reports'
  end

  def self.down
    rename_table 'reports', 'transactions'
    rename_table 'hourly_reports', 'hourly_transactions'
    rename_table 'daily_reports', 'daily_transactions'
    rename_table 'monthly_reports', 'monthly_transactions'
  end
end
