class AddDownloadsCountFieldFromReleaseFiles < ActiveRecord::Migration
  def self.up
    add_column :release_files, :downloads_count, :integer
  end

  def self.down
    remove_column :release_files, :downloads_count
  end
end
