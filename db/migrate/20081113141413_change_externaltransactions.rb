class ChangeExternaltransactions < ActiveRecord::Migration
  def self.up
    rename_table :externaltransactions, :credit_transactions

    change_table :credit_transactions do |t|
      t.rename :transactiontype, :kind
      t.string :paypal_transaction_id, :null => false, :default => ''
      t.index :paypal_transaction_id
      t.change_default :kind, 'incoming'
    end
  end

  def self.down
    change_table :credit_transactions do |t|
      t.rename :kind, :transactiontype
      t.remove :paypal_transaction_id
      t.change_default :transactiontype, 'INCOMING'
    end

    rename_table :credit_transactions, :externaltransactions
  end
end
