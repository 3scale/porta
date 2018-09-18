class AddBackendIdToCinstances < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.integer :backend_id
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove :backend_id
    end
  end
end