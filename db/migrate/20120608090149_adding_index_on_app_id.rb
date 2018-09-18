class AddingIndexOnAppId < ActiveRecord::Migration
  def self.up
    add_index :cinstances, :application_id 
  end

  def self.down
    remove_index :cinstances, :application_id
  end
end
