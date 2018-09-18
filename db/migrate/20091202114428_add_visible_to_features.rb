class AddVisibleToFeatures < ActiveRecord::Migration
  def self.up
    add_column :features, :visible, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :features, :visible
  end
end
