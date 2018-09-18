class AddDownloadsCountToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :downloads_count, :integer, :default => 0
  end

  def self.down
    remove_column :releases, :downloads_count
  end
end
