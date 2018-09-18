class AddPlanContractsCount < ActiveRecord::Migration
  def change
    add_column :plans, :contracts_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up { reset_counters }
    end
  end

  def reset_counters
    execute <<-SQL
      UPDATE plans
      LEFT JOIN (
        SELECT plans.id AS plan_id, COUNT(cinstances.id) AS count FROM plans
        LEFT JOIN cinstances ON plans.id = cinstances.plan_id
        GROUP BY plans.id) AS contracts ON plans.id = contracts.plan_id
      SET contracts_count = contracts.count;
    SQL
  end
end
