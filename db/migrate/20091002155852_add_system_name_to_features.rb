class AddSystemNameToFeatures < ActiveRecord::Migration
  def self.up
    add_column :features, :system_name, :string
    add_index :features, :system_name
  end

  def self.down
    remove_column :features, :system_name
  end
end
