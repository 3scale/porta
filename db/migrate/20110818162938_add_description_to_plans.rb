class AddDescriptionToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :description, :text
  end

  def self.down
    remove_column :plans, :description
  end
end
