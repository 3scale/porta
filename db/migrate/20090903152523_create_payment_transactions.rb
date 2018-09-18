class CreatePaymentTransactions < ActiveRecord::Migration
  def self.up
    create_table :payment_transactions do |table|
      table.belongs_to :account
      table.belongs_to :invoice
      table.boolean :success, :null => false, :default => false
      table.decimal :amount, :precision => 20, :scale => 4
      table.string :currency, :null => false, :default => 'EUR', :limit => 4
      table.string :reference
      table.string :message
      table.string :action
      table.text :params
      table.boolean :test, :null => false, :default => false
      table.timestamps
    end
  end

  def self.down
    drop_table :payment_transactions
  end
end
