class AdjustLengthOfPolymorphicColumns < ActiveRecord::Migration
  def self.up
    change_column :configuration_values, :configurable_type, :string, :limit => 50
    change_column :connectors, :connectable_type, :string, :limit => 50
    change_column :slugs, :sluggable_type, :string, :limit => 50
  end

  def self.down
    change_column :configuration_values, :configurable_type, :string, :limit => 255
    change_column :connectors, :connectable_type, :string, :limit => 255
    change_column :slugs, :sluggable_type, :string, :limit => 255
  end
end
