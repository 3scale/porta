class AddHideServiceToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :hide_service, :boolean
  end

  def self.down
    remove_column :settings, :hide_service
  end
end
