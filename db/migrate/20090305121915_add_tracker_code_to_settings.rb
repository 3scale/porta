class AddTrackerCodeToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :tracker_code, :string
    add_column :settings, :favicon, :string
  end

  def self.down
    remove_column :settings, :tracker_code
    remove_column :settings, :favicon
  end
end
