class MakingAppKeyMandatoryDefault < ActiveRecord::Migration
  def self.up
    change_column :services, :mandatory_app_key, :boolean, :default => true
  end

  def self.down
    change_column :services, :mandatory_app_key, :boolean, :default => false
  end
end
