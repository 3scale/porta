class RemoveOwnerIdFromPlans < ActiveRecord::Migration
  def self.up
    remove_column :plans, :owner_id
  end

  def self.down
    add_column :plans, :owner_id, :integer
  end
end
