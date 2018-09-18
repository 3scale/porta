class ChangeCinstancesPlanTypeDefaultValueToPlan < ActiveRecord::Migration
  def self.up
    change_column :cinstances, :plan_type, :string, :default => "Plan"
    Cinstance.update_all "plan_type = 'Plan'"
  end

  def self.down
  end
end
