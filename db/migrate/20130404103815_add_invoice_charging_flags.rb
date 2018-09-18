class AddInvoiceChargingFlags < ActiveRecord::Migration
  def up
    add_column :invoices, :charging_retries_count, :integer, default: 0, null: false
    add_column :invoices, :last_charging_retry, :date
  end

  def down
    remove_column :invoices, :charging_retries_count
    remove_column :invoices, :last_charging_retry
  end
end
