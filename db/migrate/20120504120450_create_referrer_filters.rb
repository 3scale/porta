class CreateReferrerFilters < ActiveRecord::Migration
  def self.up
    create_table :referrer_filters do |t|
      t.integer "application_id", :limit => 8, :null => false
      t.string "value", :null => false
      t.timestamps
    end
    add_index :referrer_filters, :application_id
  end

  def self.down
    drop_table :referrer_filters
  end
end
