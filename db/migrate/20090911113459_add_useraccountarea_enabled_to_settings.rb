class AddUseraccountareaEnabledToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :useraccountarea_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :useraccountarea_enabled
  end
end
