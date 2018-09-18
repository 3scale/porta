class ChangeStateInCinstance < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.remove :viewstatus
      t.remove :cistatus
      t.remove :canceled_at

      t.string :state, :null => false
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove :deleted_at
      t.remove :state

      t.datetime :canceled_at
      t.string :cistatus, :default => 'LIVE'
      t.string :viewstatus, :default => 'PRIVATE'
    end
  end
end
