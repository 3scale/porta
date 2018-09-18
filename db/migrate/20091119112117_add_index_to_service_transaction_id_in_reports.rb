class AddIndexToServiceTransactionIdInReports < ActiveRecord::Migration
  def self.up
    add_index :reports, :service_transaction_id
  end

  def self.down
    # Not necessary.
  end
end
