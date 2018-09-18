class AddMoreBrowserFieldsToDownloads < ActiveRecord::Migration
  def self.up
    add_column :downloads, :name, :string
  end

  def self.down
    remove_column :downloads, :name
  end
end
