class AddPublicSearchSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :public_search, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :settings, :public_search
  end
end
