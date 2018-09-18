class AddAccountIdToDynamicViews < ActiveRecord::Migration
  def self.up
    add_column :dynamic_views, :account_id, :integer
  end

  def self.down
    remove_column :dynamic_views, :account_id
  end
end
