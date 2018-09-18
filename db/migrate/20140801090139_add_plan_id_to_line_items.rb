class AddPlanIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :plan_id, :integer
  end
end
