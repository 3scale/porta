class AddIndexBuyerAccountIdStateToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, [:buyer_account_id, :state]
  end
end
