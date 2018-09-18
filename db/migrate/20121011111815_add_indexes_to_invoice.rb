class AddIndexesToInvoice < ActiveRecord::Migration
  def self.up
    add_index :invoices, [ :provider_account_id ]
    add_index :invoices, [ :provider_account_id, :buyer_account_id ]
    add_index :line_items, [ :invoice_id ]
  end

  def self.down
  end
end
