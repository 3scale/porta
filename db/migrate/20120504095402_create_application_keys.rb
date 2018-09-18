class CreateApplicationKeys < ActiveRecord::Migration
  def self.up
    create_table :application_keys do |t|
      t.integer "application_id", :limit => 8, :null => false
      t.string "value", :null => false
      t.timestamps
    end
    add_index :application_keys, [:application_id, :value], :unique => true
  end

  def self.down
    drop_table :application_keys
  end
end
