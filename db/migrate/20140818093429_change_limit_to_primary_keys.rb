class ChangeLimitToPrimaryKeys < ActiveRecord::Migration
  def change
    change_column :accounts, :partner_id, :integer, limit: 8
    change_column :plans, :partner_id, :integer, limit: 8
    change_column :line_items, :contract_id, :integer, limit: 8
    change_column :line_items, :plan_id, :integer, limit: 8
  end
end
