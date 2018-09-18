class RemovingToggleChecklist < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :toggle_checklist
  end

  def self.down
    add_column :accounts, :toggle_checklist, :boolean, :default => false
  end
end
