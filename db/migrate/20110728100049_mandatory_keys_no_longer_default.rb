class MandatoryKeysNoLongerDefault < ActiveRecord::Migration
  def self.up
    change_column :settings, :mandatory_app_key, :boolean, :default => false
  end

  def self.down
    change_column :settings, :mandatory_app_key, :boolean, :default => true
  end
end
