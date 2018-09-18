class AddStateFieldToReleaseFields < ActiveRecord::Migration
  def self.up
    add_column :release_files, :state, :string, :default => 'draft'
  end

  def self.down
    remove_column :release_files, :state
  end
end
