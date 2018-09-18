class RemoveLiveStateFromPlans < ActiveRecord::Migration
  def self.up
    remove_column :plans, :live_state
  end

  def self.down
    add_column :plans, :live_state, :string
  end
end
