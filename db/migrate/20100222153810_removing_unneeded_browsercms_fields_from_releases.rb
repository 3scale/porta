class RemovingUnneededBrowsercmsFieldsFromReleases < ActiveRecord::Migration
  def self.up
    remove_column :releases, :created_by
    remove_column :releases, :updated_by
  end

  def self.down
    add_column :releases, :created_by, :integer
    add_column :releases, :updated_by, :integer
  end
end
