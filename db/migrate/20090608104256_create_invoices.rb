class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :provider_account_id
      t.integer :buyer_account_id
      t.datetime :paid_at
      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
