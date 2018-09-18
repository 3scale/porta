class AddBuyerCanSelectPlanToSevices < ActiveRecord::Migration
  def self.up
    add_column :services, :buyer_can_select_plan, :boolean, :default => false
  end

  def self.down
    remove_column :services, :buyer_can_select_plan
  end
end
