class AddIndexToCreatedAtInReports < ActiveRecord::Migration
  def self.up
    add_index :reports, :created_at
  end

  def self.down
    # Not necessary...
  end
end
