class UpdateDownloadsLinkingFields < ActiveRecord::Migration
  def self.up
    remove_column :downloads, :release_id
    add_column :downloads, :release_file_id, :integer
  end

  def self.down
    add_column :downloads, :release_id, :integer
    remove_column :downloads, :release_file_id
  end
end
