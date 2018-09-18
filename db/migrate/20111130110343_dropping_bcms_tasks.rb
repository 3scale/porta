class DroppingBcmsTasks < ActiveRecord::Migration
  def self.up
    drop_table :tasks
  end

  def self.down
    create_table "tasks", :force => true do |t|
      t.integer  "assigned_by_id"
      t.integer  "assigned_to_id"
      t.integer  "page_id"
      t.text     "comment"
      t.date     "due_date"
      t.datetime "completed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end 
  end
end
