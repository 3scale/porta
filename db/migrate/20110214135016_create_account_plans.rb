class CreateAccountPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :type, :string, :null => false, :default => 'ApplicationPlan'
    add_column :plans, :owner_id, :integer
  end

  def self.down
    remove_column :plans, :type
    remove_column :plans, :owner_id
  end
end
