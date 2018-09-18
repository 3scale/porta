class AddOriginalIdToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :original_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :plans, :original_id
  end
end
