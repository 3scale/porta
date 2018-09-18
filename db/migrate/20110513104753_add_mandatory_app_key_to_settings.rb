class AddMandatoryAppKeyToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :mandatory_app_key, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :mandatory_app_key
  end
end
