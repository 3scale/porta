class AddIndicesToTransactions < ActiveRecord::Migration
  def self.up
    change_table :transactions do |t|
      t.index [:cinstance_id, :metric_id, :created_at]
    end
  end

  def self.down
    change_table :transactions do |t|
      t.remove_index [:cinstance_id, :metric_id, :created_at]
    end
  end
end
