class AddPublicToCmsSection < ActiveRecord::Migration
  def self.up
    add_column :cms_sections, :public, :boolean, :default => true
  end

  def self.down
    remove_column :cms_sections, :public
  end
end
