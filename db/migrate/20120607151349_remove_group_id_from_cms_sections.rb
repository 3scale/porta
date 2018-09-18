class RemoveGroupIdFromCmsSections < ActiveRecord::Migration
  def self.up
    remove_column :cms_sections, :group_id
  end

  def self.down
    add_column :cms_sections, :group_id, :integer, :limit => 8
  end
end
