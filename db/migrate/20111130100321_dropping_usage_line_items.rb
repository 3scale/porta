class DroppingUsageLineItems < ActiveRecord::Migration
  def self.up
    drop_table :usage_line_items
  end

  def self.down
    create_table "usage_line_items", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
