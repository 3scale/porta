class AddModuleForumSwitch < ActiveRecord::Migration
  def self.up
    add_column :settings, :module_forum_switch, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :module_forum_switch
  end
end
