class AddPublishedAtFieldToReleaseFiles < ActiveRecord::Migration
  def self.up
    add_column :release_files, :published_at, :datetime
  end

  def self.down
    remove_column :release_files, :published_at
  end
end
