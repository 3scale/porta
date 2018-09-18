class AddMoreBillingAddressFieldsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :billing_address_first_name, :string
    add_column :accounts, :billing_address_last_name, :string
  end
end
