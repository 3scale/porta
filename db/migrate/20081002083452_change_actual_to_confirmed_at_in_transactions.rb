class ChangeActualToConfirmedAtInTransactions < ActiveRecord::Migration
  def self.up
    change_table :transactions do |t|
      t.remove :actual
      t.datetime :confirmed_at
    end
  end

  def self.down
    change_table :transactions do |t|
      t.remove :confirmed_at
      t.boolean :actual, :null => false, :default => false
    end
  end
end
