class CreateConfigurationValues < ActiveRecord::Migration
  def self.up
    create_table :configuration_values do |table|
      table.belongs_to :configurable, :polymorphic => true
      table.string :name
      table.string :value
      table.timestamps
    end

    add_index :configuration_values, [:configurable_id, :configurable_type], :name => 'index_on_configurable'
    add_index :configuration_values, [:configurable_id, :configurable_type, :name], :name => 'index_on_configurable_and_name', :unique => true
  end

  def self.down
    drop_table :configuration_values
  end
end
