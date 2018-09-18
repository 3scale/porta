class AddExtraFieldsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :extra_fields, :text
  end

  def self.down
    remove_column :profiles, :extra_fields
  end
end
