class RemovePaymentSupportedCardtypesFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :payment_supported_cardtypes
  end

  def self.down
    add_column :accounts, :payment_supported_cardtypes, :string
  end
end
