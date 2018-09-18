class AddCcExpiryFieldsToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :cc_expiry_month, :integer
    add_column :accounts, :cc_expiry_year, :integer
  end

  def self.down
    remove_column :accounts, :cc_expiry_year
    remove_column :accounts, :cc_expiry_month
  end
end
