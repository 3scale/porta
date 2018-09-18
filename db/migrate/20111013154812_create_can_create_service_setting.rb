class CreateCanCreateServiceSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :can_create_service, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :settings, :can_create_service
  end
end
