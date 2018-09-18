class AddRestrictedAccessToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :restricted_access, :boolean, :default => false
  end

  def self.down
    remove_column :sections, :restricted_access
  end
end
