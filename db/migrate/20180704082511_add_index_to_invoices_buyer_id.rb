class AddIndexToInvoicesBuyerId < ActiveRecord::Migration
  def change
    add_index :invoices, :buyer_account_id
  end
end
