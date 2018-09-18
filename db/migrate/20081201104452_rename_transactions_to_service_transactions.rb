class RenameTransactionsToServiceTransactions < ActiveRecord::Migration
  def self.up
    rename_table :transactions, :service_transactions

    change_table :reports do |t|
      t.rename :transaction_id, :service_transaction_id
    end
  end

  def self.down
    rename_table :service_transactions, :transactions

    change_table :reports do |t|
      t.rename :service_transaction_id, :transaction_id
    end
  end
end
