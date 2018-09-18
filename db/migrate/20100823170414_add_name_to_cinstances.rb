class AddNameToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :name, :string
  end

  def self.down
    remove_column :cinstances, :name
  end
end
