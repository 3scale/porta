class AddParentIdToMetrics < ActiveRecord::Migration
  def self.up
    add_column :metrics, :parent_id, :integer
  end

  def self.down
    remove_column :metrics, :parent_id
  end
end
