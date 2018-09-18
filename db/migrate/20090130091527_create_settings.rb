class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :account_id
      
      t.string :bg_colour
      t.string :link_colour
      t.string :text_colour
      
      t.timestamps
    end

  end

  def self.down
    drop_table :settings
  end
end
