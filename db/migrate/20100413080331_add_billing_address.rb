class AddBillingAddress < ActiveRecord::Migration
  def self.up
    add_column :accounts, 'billing_address_name',     :string
    add_column :accounts, 'billing_address_address1', :string
    add_column :accounts, 'billing_address_address2', :string
    add_column :accounts, 'billing_address_city',     :string
    add_column :accounts, 'billing_address_state',    :string
    add_column :accounts, 'billing_address_country',  :string
    add_column :accounts, 'billing_address_zip',      :string
    add_column :accounts, 'billing_address_phone',    :string
  end

  def self.down
    remove_column :accounts, 'billing_address_name'
    remove_column :accounts, 'billing_address_address1'
    remove_column :accounts, 'billing_address_address2'
    remove_column :accounts, 'billing_address_city'
    remove_column :accounts, 'billing_address_state'
    remove_column :accounts, 'billing_address_country'
    remove_column :accounts, 'billing_address_zip'
    remove_column :accounts, 'billing_address_phone'
  end
end
