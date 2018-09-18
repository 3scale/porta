class AddUserSpecificDataToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :user_specific_data, :text
  end

  def self.down
    remove_column :cinstances, :user_specific_data
  end
end
