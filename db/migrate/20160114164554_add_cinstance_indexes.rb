class AddCinstanceIndexes < ActiveRecord::Migration
  def change
    add_index :plans, [:issuer_id, :issuer_type, :type, :original_id], name: 'idx_plans_issuer_type_original'
    add_index :cinstances, [:type, :plan_id, :service_id, :state]
  end
end
