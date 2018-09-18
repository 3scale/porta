class ChangeStateInContract < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.remove :cstatus
      t.remove :viewstatus

      t.string :state, :null => false
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :contracts do |t|
      t.remove :deleted_at
      t.remove :state

      t.string :cstatus, :default => 'OFFER'
      t.string :viewstatus, :default => 'PRIVATE'
    end
  end
end
