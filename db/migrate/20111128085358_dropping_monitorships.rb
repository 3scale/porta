class DroppingMonitorships < ActiveRecord::Migration
  def self.up
    drop_table :monitorships
  end

  def self.down
    create_table "monitorships", :force => true do |t|
      t.integer  "user_id"
      t.integer  "topic_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "active",     :default => true
    end
  end
end
