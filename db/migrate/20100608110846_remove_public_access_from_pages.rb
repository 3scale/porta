# reverts 20100603131102_add_public_to_pages.rb
class RemovePublicAccessFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :public_access
    remove_column :page_versions, :public_access
  end

  def self.down
    add_column :pages, :public_access, :boolean, :default => false
    add_column :page_versions, :public_access, :boolean, :default => false
  end
end
