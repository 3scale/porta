class DroppingUsageLimitViolations < ActiveRecord::Migration
  def self.up
    drop_table :usage_limit_violations
  end

  def self.down
    create_table "usage_limit_violations", :force => true do |t|
      t.integer  "cinstance_id"
      t.integer  "usage_limit_id"
      t.string   "period_name"
      t.datetime "period_start"
      t.string   "metric_name"
      t.integer  "limit_value",    :default => 0, :null => false
      t.integer  "actual_value",   :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "period_end"
    end

    add_index "usage_limit_violations", ["cinstance_id"], :name => "id_tempindex1"
    add_index "usage_limit_violations", ["created_at", "period_start", "period_end"], :name => "violations_timestamped_index"
    add_index "usage_limit_violations", ["period_end"], :name => "id_tempindex2"
  end
end
