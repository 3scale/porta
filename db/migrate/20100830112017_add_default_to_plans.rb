class AddDefaultToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :master, :boolean, :default => false
  end

  def self.down
    remove_column :plans, :master
  end
end
