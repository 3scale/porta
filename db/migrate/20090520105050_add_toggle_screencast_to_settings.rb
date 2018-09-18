class AddToggleScreencastToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :toggle_screencast, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :toggle_screencast
  end
end
