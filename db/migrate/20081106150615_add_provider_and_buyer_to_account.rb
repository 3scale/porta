class AddProviderAndBuyerToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :provider, :boolean, :default => false
    add_column :accounts, :buyer, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :buyer
    remove_column :accounts, :provider
  end
end
