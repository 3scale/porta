class AddDownloadedAtToDownloads < ActiveRecord::Migration
  def self.up
    add_column :downloads, :downloaded_at, :datetime
  end

  def self.down
    remove_column :downloads, :downloaded_at
  end
end
