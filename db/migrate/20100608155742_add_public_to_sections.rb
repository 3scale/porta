class AddPublicToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :public, :boolean, :default => false
  end

  def self.down
    remove_column :sections, :public
  end
end
