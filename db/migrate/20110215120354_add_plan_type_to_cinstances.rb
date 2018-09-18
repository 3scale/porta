class AddPlanTypeToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :plan_type, :string, :null => false, :default => 'ApplicationPlan'
    add_index :cinstances, :plan_type
    add_index :cinstances, [:plan_type, :plan_id]
  end

  def self.down
    remove_column :cinstances, :plan_type
  end
end
