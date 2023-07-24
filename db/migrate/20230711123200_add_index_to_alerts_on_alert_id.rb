class AddIndexToAlertsOnAlertId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    add_index :alerts, [:alert_id, :account_id], index_options
  end

  def index_options
    index_options = { unique: true }
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    index_options
  end
end
