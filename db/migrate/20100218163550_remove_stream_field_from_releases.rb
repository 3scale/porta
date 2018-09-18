class RemoveStreamFieldFromReleases < ActiveRecord::Migration
  def self.up
    remove_column :releases, :stream
  end

  def self.down
    add_column :releases, :stream, :string
  end
end
