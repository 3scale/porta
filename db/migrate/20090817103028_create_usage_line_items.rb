class CreateUsageLineItems < ActiveRecord::Migration
  def self.up
    create_table :usage_line_items do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :usage_line_items
  end
end
