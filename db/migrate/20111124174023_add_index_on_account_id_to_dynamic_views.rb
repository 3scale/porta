class AddIndexOnAccountIdToDynamicViews < ActiveRecord::Migration
  def self.up
    add_index :dynamic_views, 'account_id'
    add_index :dynamic_view_versions, 'account_id'
  end

  def self.down
    remove_index :dynamic_views, :account_id
    remove_index :dynamic_view_versions, :account_id
  end
end
