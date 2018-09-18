class AddToggleChecklistToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :toggle_checklist, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :toggle_checklist
  end
end
