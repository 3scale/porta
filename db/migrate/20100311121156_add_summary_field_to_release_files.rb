class AddSummaryFieldToReleaseFiles < ActiveRecord::Migration
  def self.up
    add_column :release_files, :summary, :string
  end

  def self.down
    remove_column :release_files, :summary
  end
end
