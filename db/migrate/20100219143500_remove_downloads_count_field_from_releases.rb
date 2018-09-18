class RemoveDownloadsCountFieldFromReleases < ActiveRecord::Migration
  def self.up
    remove_column :releases, :downloads_count
  end

  def self.down
    add_column :releases, :downloads_count, :integer
  end
end
