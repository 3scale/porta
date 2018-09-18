class RemovePlanTypeFromCinstances < ActiveRecord::Migration
  def self.up
    remove_column :cinstances, :plan_type
    remove_index :cinstances, [:plan_type, :plan_id]
  end

  def self.down
    add_column :cinstances, :plan_type, :string, :null => false, :default => 'Plan'
    add_index :cinstances, :plan_type
    add_index :cinstances, [:plan_type, :plan_id]
  end
end
