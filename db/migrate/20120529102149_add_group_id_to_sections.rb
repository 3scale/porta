class AddGroupIdToSections < ActiveRecord::Migration
  def self.up
    add_column :cms_sections, :group_id, :integer, :limit => 8
  end

  def self.down
    remove_column :cms_sections, :group_id
  end
end
