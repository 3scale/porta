class AddSampleDataFlagToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :sample_data, :boolean
  end

  def self.down
    remove_column :accounts, :sample_data
  end
end
