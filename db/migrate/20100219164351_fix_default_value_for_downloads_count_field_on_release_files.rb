class FixDefaultValueForDownloadsCountFieldOnReleaseFiles < ActiveRecord::Migration
  def self.up
    change_column :release_files, :downloads_count, :integer, :default => 0
  end

  def self.down
    change_column :release_files, :downloads_count, :integer
  end
end
