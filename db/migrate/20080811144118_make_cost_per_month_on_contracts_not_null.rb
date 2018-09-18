class MakeCostPerMonthOnContractsNotNull < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.change :cost_per_month, :decimal, :precision => 10, :scale => 2, :null => false, :default => 0
    end
  end

  def self.down
    change_table :contracts do |t|
      t.change :cost_per_month, :integer
    end
  end
end
