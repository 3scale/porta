class AddPaymentSupportedCardtypesToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :payment_supported_cardtypes, :string
  end

  def self.down
    remove_column :accounts, :payment_supported_cardtypes
  end
end
