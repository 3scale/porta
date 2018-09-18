class ChangeStateInServices < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.remove :viewstatus
      t.remove :pestatus

      t.string :state, :null => false
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :services do |t|
      t.remove :deleted_at
      t.remove :state

      t.string :pestatus, :default => 'ACTIVE'
      t.string :viewstatus, :default => 'PUBLIC'
    end
  end
end
