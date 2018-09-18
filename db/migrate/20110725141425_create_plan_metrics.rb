class CreatePlanMetrics < ActiveRecord::Migration
  def self.up
    create_table :plan_metrics do |t|
      t.references :plan
      t.references :metric
      t.boolean :visible, :default => true
      t.boolean :limits_only_text, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :plan_metrics
  end
end
