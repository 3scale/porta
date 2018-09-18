class RemovingExtraFieldsFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :extra_fields
  end

  def self.down
    add_column :profiles, :extra_fields, :text
  end
end
