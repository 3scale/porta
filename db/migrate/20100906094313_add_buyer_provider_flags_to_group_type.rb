class AddBuyerProviderFlagsToGroupType < ActiveRecord::Migration
  def self.up
    add_column :group_types, :buyer, :boolean, :default => false
    add_column :group_types, :provider, :boolean, :default => true
  end

  def self.down
    remove_column :group_types, :buyer
    remove_column :group_types, :provider
  end
end
