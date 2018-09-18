class RemoveParentIdFromPlans < ActiveRecord::Migration
  def self.up
    remove_column :plans, :parent_id
  end

  def self.down
    add_column :plans, :parent_id, :integer
  end
end
