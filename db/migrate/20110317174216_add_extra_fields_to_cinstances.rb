class AddExtraFieldsToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :extra_fields, :text
  end

  def self.down
    remove_column :cinstances, :extra_fields
  end
end
