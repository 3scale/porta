class AddIndexOnPaymentTransactionsInvoiceId < ActiveRecord::Migration
  def up
    add_index :payment_transactions, :invoice_id
  end

  def down
    remove_index :payment_transactions, :invoice_id
  end
end
