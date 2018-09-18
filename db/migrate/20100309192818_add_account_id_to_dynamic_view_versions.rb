class AddAccountIdToDynamicViewVersions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_view_versions, :account_id, :integer
  end

  def self.down
    remove_column :dynamic_view_versions, :account_id
  end
end
