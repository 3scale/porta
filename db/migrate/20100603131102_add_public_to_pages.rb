class AddPublicToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :public_access, :boolean, :default => false
    add_column :page_versions, :public_access, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :public_access
    remove_column :page_versions, :public_access
  end
end
