class RemovingUnneededBrowsercmsFieldsFromDownloads < ActiveRecord::Migration
  def self.up
    remove_column :downloads, :name
    remove_column :downloads, :slug
    remove_column :downloads, :deleted
    remove_column :downloads, :archived
    remove_column :downloads, :created_by
    remove_column :downloads, :updated_by
  end

  def self.down
    add_column :downloads, :name, :string
    add_column :downloads, :slug, :string
    add_column :downloads, :deleted, :boolean, :default => false
    add_column :downloads, :archived, :boolean, :default => false
    add_column :downloads, :created_by, :integer
    add_column :downloads, :updated_by, :integer
  end
end
